pipeline {
  agent {
    label "k8s-slave"
    }
  environment {
    ORG = 'curefoods-infra'
    PROD_ORG = 'curefoods-infra-prod'
    DOCKER_REGISTRY = 'gcr.io'
    APP_NAME = 'graphhopper'
    GITHUB_NPM_TOKEN = credentials('github-npm-token')
    SERVICE_ACCOUNT_CRED_STAGE = credentials('service-account-credentials-stage')
    SERVICE_ACCOUNT_CRED_PROD = credentials('service-account-credentials-prod')
    AWS_CRED = credentials('cf-superuser')
    }
  stages {
    stage('Prepare Docker Image for Stage Environment') {
      when { branch 'curefoods-migration-gcp' }
      environment {
        VERSION = "$BUILD_NUMBER-$BRANCH_NAME".replaceAll('_','-')
        }
      steps {
          script{
            def URL = "${DOCKER_REGISTRY}/${ORG}/${APP_NAME}:${VERSION}"
            buildDockerfile("${APP_NAME}", URL, "stage")
            pushDockerImage(URL)
            updateArtifact("${DOCKER_REGISTRY}/${ORG}/${APP_NAME}", "${VERSION}", "stage")
            deployV2(APP_NAME, VERSION, ORG, "stage")
            }
          }
      };
    stage('Prepare Docker Image for Alpha Environment') {
          when { branch 'alpha' }
          environment {
            VERSION = "$BUILD_NUMBER-$BRANCH_NAME".replaceAll('_','-')
            }
          steps {
              script{
                def URL = "${DOCKER_REGISTRY}/${ORG}/${APP_NAME}:${VERSION}"
                buildDockerfile("${APP_NAME}", URL, "prod")
                pushDockerImage(URL)
                updateArtifact("${DOCKER_REGISTRY}/${ORG}/${APP_NAME}", "${VERSION}", "prod")
              }
            }
          };
    stage('Prepare Docker Image for Production Environment') {
      when{ branch 'curefoods-migration-gcp-master'; }
       environment {
        VERSION = "$BUILD_NUMBER"
        }
      steps {
          script{
            def URL = "${DOCKER_REGISTRY}/${PROD_ORG}/${APP_NAME}:${VERSION}"
            buildDockerfile("${APP_NAME}", URL, "prod")
            pushDockerImage(URL)
            updateArtifact("${DOCKER_REGISTRY}/${PROD_ORG}/${APP_NAME}", "${VERSION}", "prod")
            timeout(time: 10, unit: 'MINUTES') {
                input(id: "Deploy Gate", message: "Deploy ${APP_NAME}?", ok: 'Deploy')
            }
            deployV2(APP_NAME, VERSION, PROD_ORG, "prod")
          }
        }
      };
  }
  post {
    success {
      cleanWs()
      }
  }
}

void buildDockerfile(appName, tag, env){
  sh "sudo docker build -t ${tag} --build-arg GITHUB_NPM_TOKEN=${GITHUB_NPM_TOKEN} --build-arg AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} --build-arg AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} --build-arg ENVIRONMENT=${env} --build-arg APP_NAME=${appName} --network host ."
}

void pushDockerImage(tag){
   sh "sudo docker push ${tag}"
}

void updateArtifact(repo, tag, env) {
    sh """
    touch build.properties
    echo repo=${repo} >> build.properties
    echo tag=${tag} >> build.properties
    echo env=${env} >> build.properties
    """
    archiveArtifacts 'build.properties'
}

void deployV2(APP_NAME, tag, org, env) {
  def SERVICE_ACCOUNT_CRED="${SERVICE_ACCOUNT_CRED_STAGE}"
  if(env == "prod") {
    SERVICE_ACCOUNT_CRED="${SERVICE_ACCOUNT_CRED_PROD}"
  }
    sh """
    find . -maxdepth 1 ! -name 'cd' ! -name "*.yaml" ! -name '.' -exec rm -rf {} +
    cd cd
    find . -maxdepth 1 ! -name 'deploy.sh' ! -name '.' -exec rm -rf {} +
    chmod +x deploy.sh
    ./deploy.sh ${APP_NAME} ${env} ${tag} ${SERVICE_ACCOUNT_CRED} ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} "${DOCKER_REGISTRY}/${org}/${APP_NAME}"
    """
}