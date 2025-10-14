type MetricType = 'counter' | 'gauge' | 'histogram';

const DURATION_BUCKETS = [100, 300, 1000, 2000, 5000, 10000];

interface Histogram {
  buckets: number[];
  sum: number;
  count: number;
}

interface CounterEntry {
  name: string;
  labels: Record<string, string>;
  value: number;
}

interface MetadataEntry {
  help: string;
  type: MetricType;
}

function labelsKey(labels: Record<string, string>): string {
  const entries = Object.entries(labels);
  if (entries.length === 0) {
    return '';
  }
  return entries
    .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))
    .map(([k, v]) => `${k}="${v.replace(/"/g, '\\"')}"`)
    .join(',');
}

class MetricsService {
  private static instance: MetricsService;

  private histograms = new Map<string, Histogram>();
  private counters = new Map<string, CounterEntry>();
  private metadata = new Map<string, MetadataEntry>();

  private constructor() {}

  static getInstance(): MetricsService {
    if (!MetricsService.instance) {
      MetricsService.instance = new MetricsService();
    }
    return MetricsService.instance;
  }

  private registerMetric(name: string, help: string, type: MetricType) {
    if (!this.metadata.has(name)) {
      this.metadata.set(name, { help, type });
    }
  }

  recordJobDuration(stage: string, ms: number) {
    this.registerMetric('starlist_job_duration_ms', 'Job duration histogram', 'histogram');
    let histogram = this.histograms.get(stage);
    if (!histogram) {
      histogram = { buckets: Array(DURATION_BUCKETS.length).fill(0), sum: 0, count: 0 };
      this.histograms.set(stage, histogram);
    }
    histogram.count += 1;
    histogram.sum += ms;
    for (let i = 0; i < DURATION_BUCKETS.length; i += 1) {
      if (ms <= DURATION_BUCKETS[i]) {
        histogram.buckets[i] += 1;
      }
    }
  }

  incrementCounter(
    name: string,
    labels: Record<string, string> = {},
    help = '',
  ) {
    this.registerMetric(name, help || `${name} counter`, 'counter');
    const key = `${name}|${labelsKey(labels)}`;
    const entry = this.counters.get(key);
    if (entry) {
      entry.value += 1;
    } else {
      this.counters.set(key, { name, labels, value: 1 });
    }
  }

  incrementError(code: string) {
    this.incrementCounter('starlist_errors_total', { code }, 'Errors by code');
  }

  incrementLowConfidence() {
    this.incrementCounter('starlist_ocr_low_conf_total', {}, 'Low-confidence OCR occurrences');
  }

  incrementExternalUsage() {
    this.incrementCounter('starlist_ocr_fallback_total', {}, 'External OCR fallback used');
  }

  renderPrometheus(): string {
    const lines: string[] = [];

    if (this.histograms.size > 0) {
      lines.push('# HELP starlist_job_duration_ms Job duration histogram');
      lines.push('# TYPE starlist_job_duration_ms histogram');
      const stages = Array.from(this.histograms.keys()).sort();
      for (const stage of stages) {
        const hist = this.histograms.get(stage)!;
        for (let i = 0; i < DURATION_BUCKETS.length; i += 1) {
          lines.push(
            `starlist_job_duration_ms_bucket{stage="${stage}",le="${DURATION_BUCKETS[i]}"} ${hist.buckets[i]}`,
          );
        }
        lines.push(`starlist_job_duration_ms_bucket{stage="${stage}",le="+Inf"} ${hist.count}`);
        lines.push(`starlist_job_duration_ms_sum{stage="${stage}"} ${hist.sum}`);
        lines.push(`starlist_job_duration_ms_count{stage="${stage}"} ${hist.count}`);
      }
    }

    const counters = Array.from(this.counters.values()).sort((a, b) => {
      if (a.name === b.name) {
        return labelsKey(a.labels) < labelsKey(b.labels) ? -1 : 1;
      }
      return a.name < b.name ? -1 : 1;
    });

    let lastName = '';
    for (const entry of counters) {
      if (entry.name !== lastName) {
        const meta = this.metadata.get(entry.name);
        if (meta) {
          lines.push(`# HELP ${entry.name} ${meta.help}`);
          lines.push(`# TYPE ${entry.name} ${meta.type}`);
        }
        lastName = entry.name;
      }
      const labels = labelsKey(entry.labels);
      const labelSuffix = labels ? `{${labels}}` : '';
      lines.push(`${entry.name}${labelSuffix} ${entry.value}`);
    }

    return lines.join('\n');
  }
}

export const metricsService = MetricsService.getInstance();
