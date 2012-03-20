config ={}
dynect_file = YAML.load_file("#{Rails.root}/config/dynect.yml")
config['dynect'] = dynect_file[Rails.env]

::AppConfig = config