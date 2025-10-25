const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors({
    origin: '*', // Allow all origins (for development/testing)
    methods: ['GET', 'POST', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// MariaDB connection pool
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'logdb',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Initialize database and table
async function initDatabase() {
    try {
        const connection = await pool.getConnection();
        
        // Create database if it doesn't exist
        await connection.query(`CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME || 'logdb'}`);
        await connection.query(`USE ${process.env.DB_NAME || 'logdb'}`);
        
        // Create logs table if it doesn't exist
        await connection.query(`
            CREATE TABLE IF NOT EXISTS logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                message TEXT NOT NULL,
                source VARCHAR(100),
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                metadata JSON,
                INDEX idx_timestamp (timestamp)
            )
        `);
        
        connection.release();
        console.log('✓ Database and table initialized');
    } catch (error) {
        console.error('Database initialization error:', error);
        throw error;
    }
}

// API Routes

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Get all logs
app.get('/api/logs', async (req, res) => {
    try {
        const [rows] = await pool.query(
            'SELECT * FROM logs ORDER BY timestamp DESC LIMIT 100'
        );
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error fetching logs:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Create a new log entry
app.post('/api/logs', async (req, res) => {
    try {
        const { message, source, metadata } = req.body;
        
        // Validation
        if (!message) {
            return res.status(400).json({ 
                success: false, 
                error: 'Message is required' 
            });
        }

        const [result] = await pool.query(
            'INSERT INTO logs (message, source, metadata) VALUES (?, ?, ?)',
            [message, source || null, JSON.stringify(metadata || {})]
        );

        res.status(201).json({ 
            success: true, 
            data: { 
                id: result.insertId,
                message,
                source,
                metadata
            }
        });
    } catch (error) {
        console.error('Error creating log:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Delete a log entry
app.delete('/api/logs/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const [result] = await pool.query('DELETE FROM logs WHERE id = ?', [id]);
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, error: 'Log not found' });
        }
        
        res.json({ success: true, message: 'Log deleted successfully' });
    } catch (error) {
        console.error('Error deleting log:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Clear all logs
app.delete('/api/logs', async (req, res) => {
    try {
        await pool.query('TRUNCATE TABLE logs');
        res.json({ success: true, message: 'All logs cleared' });
    } catch (error) {
        console.error('Error clearing logs:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Start server
async function startServer() {
    try {
        await initDatabase();
        app.listen(PORT, '0.0.0.0', () => {
            console.log(`✓ Server running on http://0.0.0.0:${PORT}`);
            console.log(`✓ Health check: http://localhost:${PORT}/api/health`);
            console.log(`✓ API endpoint: http://localhost:${PORT}/api/logs`);
        });
    } catch (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
    }
}

startServer();
