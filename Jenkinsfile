#!groovy
import groovy.json.JsonSlurperClassic
node {

    def BUILD_NUMBER=env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR="tests/${BUILD_NUMBER}"
    def SFDC_USERNAME

    def HUB_ORG=env.HUB_ORG_DH
    def SFDC_HOST = env.SFDC_HOST_DH
    def JWT_KEY_CRED_ID = env.JWT_CRED_ID_DH
    def CONNECTED_APP_CONSUMER_KEY=env.CONNECTED_APP_CONSUMER_KEY_DH

    println 'KEY IS' 
    println JWT_KEY_CRED_ID
    println HUB_ORG
    println SFDC_HOST
    println CONNECTED_APP_CONSUMER_KEY

    stage('checkout source') {
        // when running in multi-branch job, one must issue this command
        checkout scm
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
        // stage('Clean-Up') {
        //     deleteDir()
        // }
        stage('Deploye Code') {
            if (isUnix()) {
                rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --client-id ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwt-key-file ${jwt_key_file} --set-default-dev-hub --instanceurl ${SFDC_HOST} --alias HubOrg"
            }else{
                 rc = bat returnStatus: true, script: "sfdx force:auth:jwt:grant --client-id ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwt-key-file \"${jwt_key_file}\" --set-default-dev-hub --instanceurl ${SFDC_HOST} --alias HubOrg"
                //  v1 = bat returnStdout: true, script : "sf config set target-org HubOrg"
                
            }
            if (rc != 0) { error 'hub org authorization failed' }

			println rc
			
			// need to pull out assigned username
			if (isUnix()) {
				rmsg = sh returnStdout: true, script: "sf project deploy start -u ${HUB_ORG}"
			}else{
                rmsg = bat returnStdout: true, script: "sfdx force:source:deploy --manifest manifest/package.xml  -u ${HUB_ORG}"
			}
  
            printf rmsg
            println('Hello from a Job DSL script!')
            println(rmsg)
        }


        //create scratch org
        stage('Create Test Scratch Org') {
            if(isUnix()){
                rmsg = sh returnStdout: true, script: "sf org create scratch --target-dev-hub HubOrg --set-default --definition-file config/project-scratch-def.json --alias Org7 --wait 10 --duration-days 1 SF_DISABLE_DNS_CHECK=true"
            }else{
                rmsg = bat returnStdout: true, script: "sf org create scratch --target-dev-hub HubOrg --set-default --definition-file config/project-scratch-def.json --alias Org7 --wait 10 --duration-days 1"
                v2 = bat returnStdout: true, script : "sf config set target-org Org7"
            }

            println('rmsg : ' + rmsg);
        }

        stage('Generate username and password'){
            rmsg = bat returnStdout: true , script: "sf org generate password --target-org Org7 --length 20"
        }

        stage('Display user'){
            rmsg = bat returnStdout: true , script: "sf org display user --target-org Org7"
        }

        // Deploy code to scratch org

        stage('Push To Test Scratch Org') {
            if(isUnix()){
                rmsg1 = sh returnStdout: true, script: "sf project deploy start --target-org Org7";
            }else{
                rmsg1 = bat returnStdout: true, script: "sf project deploy start --target-org Org7"
            }
        }
    }
}