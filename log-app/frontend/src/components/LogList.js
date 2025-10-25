import React from 'react';

function LogList({ logs, onDelete }) {
  const formatTimestamp = (timestamp) => {
    return new Date(timestamp).toLocaleString();
  };

  if (logs.length === 0) {
    return <div className="no-logs">No command entries found</div>;
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
        </div>
      ))}
    </div>
  );
}

export default LogList;
