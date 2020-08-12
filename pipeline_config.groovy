pipeline_template = "web"

application_environments{
    approvers{
        IT = ""
        bussiness = ""
    }       
    dev{
    }
    staging{
    }
    prod{        
    }
}

libraries{
    git{
        source_type = "github"
    }
    sonarqube{
        appWorkSpace = "."
    }
    angularjs
    slack
    web
}
