import React from 'react';

function LogList({ logs, onDelete }) {
  const formatTimestamp = (timestamp) => {
    return new Date(timestamp).toLocaleString();
  };

  const formatMetadata = (metadata) => {
    try {
      const parsed = typeof metadata === 'string' ? JSON.parse(metadata) : metadata;
      return JSON.stringify(parsed, null, 2);
    } catch {
      return metadata;
    }
  };

  if (logs.length === 0) {
    return <div className="no-logs">No log entries found</div>;
  }

  return (
    <div className="log-list">
      {logs.map((log) => (
        <div key={log.id} className="log-item">
          <div className="log-header">
            <span className="log-timestamp">{formatTimestamp(log.timestamp)}</span>
            <button
              onClick={() => onDelete(log.id)}
              className="btn-delete"
              title="Delete log"
            >
              ✕
            </button>
          </div>
          <div className="log-message">{log.message}</div>
          {log.source && (
            <div className="log-source">
              <strong>Source:</strong> {log.source}
            </div>
          )}
          {log.metadata && log.metadata !== '{}' && (
            <details className="log-metadata">
              <summary>Metadata</summary>
              <pre>{formatMetadata(log.metadata)}</pre>
            </details>
          )}
        </div>
      ))}
    </div>
  );
}

export default LogList;
