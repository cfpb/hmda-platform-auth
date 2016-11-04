from collections import defaultdict
from flask import abort, Flask, jsonify, request
from flask_cors import CORS
from pprint import pprint
from werkzeug.exceptions import BadRequest

app = Flask(__name__)
CORS(app)

institutions = [
    {'id': '1', 'rssd_id': '11111', 'fdic_charter': '987', 'name': 'ABC Bank',    'domain': ['abcbank.com']},
    {'id': '2', 'rssd_id': '22222', 'fdic_charter': '823', 'name': 'XYZ Bank',    'domain': ['xyzbank.com']},
    {'id': '3', 'rssd_id': '33333', 'fdic_charter': '123', 'name': 'First Bank',  'domain': ['1stbank.com', 'firstbank.com']},
    {'id': '4', 'rssd_id': '44444', 'fdic_charter': '656', 'name': 'Second Bank', 'domain': ['2ndbank.com', 'secondbank.com']}
]

inst_by_attr = defaultdict(dict)
for inst in institutions:
    for inst_attr_key, inst_attr_val in inst.items():
        inst_attr_map = inst_by_attr[inst_attr_key]

        # FIXME: Make this a general `is list` check.
        if inst_attr_key == 'domain':
            for domain in inst_attr_val:
                try:
                    # FIXME: This allows dupe insts 
                    inst_attr_map[domain].add(inst)
                except KeyError:
                    inst_attr_map[domain] = [inst]
        else:
            try:
                # FIXME: This allows dupe insts
                inst_attr_map[inst_attr_val].add(inst)
            except KeyError:
                inst_attr_map[inst_attr_val] = [inst]


def search_name(search_str):
    return [i for i in institutions if search_str.lower() in i['name'].lower()]


@app.route('/', methods=['GET'])
def home():

    resp = {'message': 'Welcome to the CFPB\'s Institutions API'}

    return jsonify(resp)


@app.route('/institutions')
def get_institutions():
    params = request.args
    results=institutions

    if params:

        search_str = params.get('search', None)
    
        if search_str:
            results=search_name(search_str)
        else:
            for param_key, param_val in params.items():
                # FIXME: `results` only based on last param
                try:
                    results = inst_by_attr[param_key][param_val]
                except KeyError:
                    results = []
        

    return jsonify(results=results)


@app.route('/institutions/<id>')
def get_institution_by_id(id):
    try:
        inst = inst_by_id[id]
        return jsonify(inst)
    except KeyError as ke:
        abort(404)
        

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
