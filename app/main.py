from flask import Flask, render_template, jsonify
import os
import socket
import platform
from datetime import datetime


app = Flask(__name__)

# Get version from environment variable (useful for CI/CD)
APP_VERSION = os.getenv('APP_VERSION', '1.0.0')
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')


@app.route('/')
def home():
    # Homepage displaying application info
    return render_template('index.html', 
                         version=APP_VERSION,
                         environment=ENVIRONMENT,
                         hostname=socket.gethostname())


@app.route('/health')
def health():
    # Health check endpoint for load balancer
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/api/info')
def info():
    # API endpoint returning system information
    return jsonify({
        'app_version': APP_VERSION,
        'environment': ENVIRONMENT,
        'hostname': socket.gethostname(),
        'platform': platform.platform(),
        'python_version': platform.python_version(),
        'timestamp': datetime.utcnow().isoformat()
    })

if __name__ == '__main__':
    # Get port from environment variable (useful for Docker)
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=(ENVIRONMENT == 'development'))