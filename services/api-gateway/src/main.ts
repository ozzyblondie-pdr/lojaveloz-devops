import './tracing';
import express from 'express';
import rateLimit from 'express-rate-limit';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { logger } from './logger';

const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ status: 'UP', service: 'api-gateway' });
});

const limiter = rateLimit({
  windowMs: 60 * 1000,
  max: 100,
  message: { error: 'Too many requests' },
});
app.use(limiter);

app.use('/api/v1/orders', createProxyMiddleware({
  target: process.env.ORDER_SERVICE_URL || 'http://order-service:8081',
  changeOrigin: true,
  on: {
    error: (err, _req, res: any) => {
      logger.error({ err }, 'Proxy error to order-service');
      res.status(502).json({ error: 'Order service unavailable' });
    },
  },
}));

app.use('/api/v1/payments', createProxyMiddleware({
  target: process.env.PAYMENT_SERVICE_URL || 'http://payment-service:8082',
  changeOrigin: true,
  on: {
    error: (err, _req, res: any) => {
      logger.error({ err }, 'Proxy error to payment-service');
      res.status(502).json({ error: 'Payment service unavailable' });
    },
  },
}));

app.use('/api/v1/stock', createProxyMiddleware({
  target: process.env.STOCK_SERVICE_URL || 'http://stock-service:8083',
  changeOrigin: true,
}));

app.listen(PORT, () => {
  logger.info({ port: PORT }, 'API Gateway started');
});
