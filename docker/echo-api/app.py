from flask import Flask, jsonify, request
from werkzeug.exceptions import BadRequest 

app = Flask(__name__)

def build_response(request):
    resp = {
        "path": request.path,
        "url": request.url,
        "method": request.method,
        "cookies": {c[0]: c[1] for c in request.cookies},
        "headers": {h[0]: h[1] for h in request.headers},
        "values": request.values, #{v[0]: v[1] for v in request.values}
    }

    raw_data = request.data
    if raw_data:
        resp['body'] = raw_data

    try:
        resp['body'] = request.get_json(force=True)
    except BadRequest:
        pass

    return resp


methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS', 'HEAD']

@app.route('/', defaults={'path': ''}, methods=methods)
@app.route('/<path:path>', methods=methods)
def echo(path):

    resp = build_response(request)

    return jsonify(resp)


def gen_error_json(message, code):
    """
    Builds standard JSON error message
    """
    resp = build_response(request)
    resp['message'] = message
    resp['statusCode'] = code

    return jsonify(resp), code

# Register all Flask error handlers
@app.errorhandler(404)
def not_found_error(error):
    return gen_error_json('Resource not found', 404)

@app.errorhandler(403)
def forbidden_error(error):
    print("Yep, you're in the Forbidden error hander!")
    return gen_error_json(error.description, 403)

@app.errorhandler(Exception)
def default_error(error):
    app.logger.exception('Internal server error')
    return gen_error_json('Internal server error', 500)

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
