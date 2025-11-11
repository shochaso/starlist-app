const DURATION_BUCKETS = [100, 300, 1000, 2000, 5000, 10000];
function labelsKey(labels) {
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
    static instance;
    histograms = new Map();
    counters = new Map();
    metadata = new Map();
    constructor() { }
    static getInstance() {
        if (!MetricsService.instance) {
            MetricsService.instance = new MetricsService();
        }
        return MetricsService.instance;
    }
    registerMetric(name, help, type) {
        if (!this.metadata.has(name)) {
            this.metadata.set(name, { help, type });
        }
    }
    recordJobDuration(stage, ms) {
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
    incrementCounter(name, labels = {}, help = '') {
        this.registerMetric(name, help || `${name} counter`, 'counter');
        const key = `${name}|${labelsKey(labels)}`;
        const entry = this.counters.get(key);
        if (entry) {
            entry.value += 1;
        }
        else {
            this.counters.set(key, { name, labels, value: 1 });
        }
    }
    incrementError(code) {
        this.incrementCounter('starlist_errors_total', { code }, 'Errors by code');
    }
    incrementLowConfidence() {
        this.incrementCounter('starlist_ocr_low_conf_total', {}, 'Low-confidence OCR occurrences');
    }
    incrementExternalUsage() {
        this.incrementCounter('starlist_ocr_fallback_total', {}, 'External OCR fallback used');
    }
    renderPrometheus() {
        const lines = [];
        if (this.histograms.size > 0) {
            lines.push('# HELP starlist_job_duration_ms Job duration histogram');
            lines.push('# TYPE starlist_job_duration_ms histogram');
            const stages = Array.from(this.histograms.keys()).sort();
            for (const stage of stages) {
                const hist = this.histograms.get(stage);
                for (let i = 0; i < DURATION_BUCKETS.length; i += 1) {
                    lines.push(`starlist_job_duration_ms_bucket{stage="${stage}",le="${DURATION_BUCKETS[i]}"} ${hist.buckets[i]}`);
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
