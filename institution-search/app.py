from collections import defaultdict
from flask import abort, Flask, jsonify, request
from flask_cors import CORS
from pprint import pprint
from werkzeug.exceptions import BadRequest
import yaml

institutions = None

with open("data/institutions.yaml", 'r') as f:
    institutions = yaml.safe_load(f)['institutions']

app = Flask(__name__)
CORS(app)

inst_by_domain = {}

for inst in institutions:
    for domain in inst['domains']:
        try:
            inst_by_domain[domain].append(inst)
        except KeyError:
            inst_by_domain[domain] = [inst]


@app.route('/', methods=['GET'])
def home():
    resp = {'message': 'Welcome to the CFPB\'s Institutions API'}

    return jsonify(resp)


@app.route('/institutions')
def get_institutions():
    domain = request.args['domain']
    results = inst_by_domain.get(domain, [])

    return jsonify(results=results)
       

def gen_error_json(message, code):
    """
    Builds standard JSON error message
    """
    resp = {'message': message, 'statusCode': code}

    return jsonify(resp), code

# Register all Flask error handlers
@app.errorhandler(404)
def not_found_error(error):
    return gen_error_json('Resource not found', 404)

@app.errorhandler(Exception)
def default_error(error):
    app.logger.exception('Internal server error: {}'.format(error))
    return gen_error_json('Internal server error', 500)

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
