import os
import json
import sys

alfred_workdata_dir = os.environ['alfred_workflow_data']
sys.stderr.write(alfred_workdata_dir)
try:
    os.makedirs(alfred_workdata_dir)
except:
    pass

def read_config():
    # default config
    default_config = dict(current='163')

    # read config file, if not create default one
    config_file = os.path.join(alfred_workdata_dir,'config.json')

    config = {}
    if not os.path.isfile(config_file):
        with open(config_file, 'w') as f:
            f.write(json.dumps(default_config))
        config = default_config
    else:
        with open(config_file, 'r') as f:
            s = f.read()
            config = json.loads(s)
    return config

def write_config(config):
    config_file = os.path.join(alfred_workdata_dir,'config.json')
    with open(config_file, 'w') as f:
        f.write(json.dumps(config))


def alfred_output():
    item_template = '''
    <title>%s</title>
    <subtitle>%s</subtitle>
    <icon type="%s">%s</icon>
    '''
    config = read_config()
    item_string = '<items>'
    for s in config['sources']:
        uid, arg, title, subtitle, icon_type, icon_name = s, s, s, s, 'png', 'empty.png'
        if s == config['current']:
            title += '-current'
        item_string += '<item arg="%s" uid="%s">' % (uid, arg,)
        item_string += item_template % (title, subtitle, icon_type, icon_name)
        item_string += '</item>'
    item_string += '</items>'

    sys.stdout.write(item_string)

if __name__ == '__main__':
    param = sys.argv[1]
    if param == 'alfred':
        alfred_output()
    elif param == 'get_source_string':
        sys.stdout.write(read_config()['current'])
    elif param == 'set_source':
        config=read_config()
        config.update(dict(current=sys.argv[2]))
        write_config(config)
