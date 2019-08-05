import integrationtest_pb2
import yaml

import base64
import json
import os.path


def make_int32_test(n):
    int32_test = integrationtest_pb2.Int32Test()
    int32_test.value = n
    return int32_test


def make_string_test(s):
    string_test = integrationtest_pb2.StringTest()
    string_test.value = s
    return string_test


def read_in(in_filepath):
    f = open(in_filepath, encoding='utf-8')
    return yaml.load(f)


def write_out(inputs, making_func, out_filepath):
    result = {
        input['description']: {
            'decoded': input['value'],
            'encoded': base64.b64encode(making_func(input['value']).SerializeToString()).decode('ascii')
        }
        for input in inputs
    }
    json_string = json.dumps(result, indent=2)

    f = open(out_filepath, 'w')
    f.write(json_string)
    f.close()


parent_directory_of_this_script = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

input_dictionary = read_in(os.path.join(parent_directory_of_this_script, 'input.yaml'))

out_filepath = os.path.join(parent_directory_of_this_script, 'int32_test.json')
write_out(input_dictionary['int32'], make_int32_test, out_filepath)

out_filepath = os.path.join(parent_directory_of_this_script, 'string_test.json')
write_out(input_dictionary['string'], make_string_test, out_filepath)
