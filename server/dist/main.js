import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module.js';
async function bootstrap() {
    const app = await NestFactory.create(AppModule, {
        cors: {
            origin: [/^http:\/\/localhost:\d+$/],
            credentials: true,
        },
    });
    const port = process.env.PORT || 3000;
    await app.listen(port);
    // eslint-disable-next-line no-console
    console.log('[server] up on', await app.getUrl());
}
bootstrap();
