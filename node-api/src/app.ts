import express, { Application } from 'express';
import tasksRoutes from './routes/tasksRoutes';
import swaggerUi from 'swagger-ui-express';
import swaggerDocument from '../swagger.json';

const app: Application = express();
app.use(express.json());

// Configuração do Swagger
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

// Rota inicial
app.get('/', (req, res) => {
  res.status(200).json({ message: "API is running" });
});

// Rotas
app.use('/tasks', tasksRoutes);

export default app;
