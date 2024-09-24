local all_dashboards = import 'mixin/dashboards/all.libsonnet';

local config = {
    selected_dashboards: ['ec2.json','rds.json', 'ebs.json']
};


local exported_dashboards = { 
    ['aws-'+key]: all_dashboards[key] 
    for key in std.objectFields(all_dashboards) 
    if std.member(config.selected_dashboards, key) 
};


exported_dashboards
