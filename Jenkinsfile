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

    def SCRATCH_ORG_ALIAS = 'Org10'
    def TEST_LEVEL='RunLocalTests'

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
            rc = command "sfdx force:auth:jwt:grant --client-id ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwt-key-file \"${jwt_key_file}\" --set-default-dev-hub --instanceurl ${SFDC_HOST} --alias HubOrg" 
            if (rc != 0) { error 'hub org authorization failed' }

			println rc
        }


        //create scratch org
        stage('Create Test Scratch Org') {
            rmsg = command "sf org create scratch --target-dev-hub HubOrg --set-default --definition-file config/project-scratch-def.json --alias ${SCRATCH_ORG_ALIAS} --wait 30 --duration-days 1"
            v2 = bat returnStatus: true, script : "sf config set target-org ${SCRATCH_ORG_ALIAS}"
            if(rmsg != 0){error 'Scratch Org creation failed'}

            println('rmsg : ' + rmsg);
        }

        stage('Generate username and password'){
            rmsg = command "sf org generate password --target-org ${SCRATCH_ORG_ALIAS} --length 20"
            if(rmsg != 0){error 'Scratch Org username and password generation failed'}
        }

        stage('Display user'){
            rmsg =command "sf org display user --target-org ${SCRATCH_ORG_ALIAS}"
            if(rmsg != 0){error 'Scratch Org display user failed'} 
        }

        // Deploy code to scratch org

        stage('Push To Test Scratch Org') {
            rmsg1 = command "sf project deploy start --target-org ${SCRATCH_ORG_ALIAS}"
            if(rmsg != 0){error 'Scratch Org deployment failed'}
        }

        stage('Run Tests In Test Scratch Org') {
            rc = command "sf apex run test --target-org ${SCRATCH_ORG_ALIAS} --wait 10 --result-format tap --code-coverage --test-level ${TEST_LEVEL}"
            if (rc != 0) { error 'Salesforce unit test run in test scratch org failed.'}
        }
    }

    // post {
    //     always {
    //         bat returnStatus: true, script: "sf apex run --target-org ${SCRATCH_ORG_ALIAS} --file ~/GetContacts.cls"
    //     }
    // }
}

def command(script){
    if(isUnix()){
        return sh(returnStatus: true, script:script)
    }else{
        return bat (returnStatus:true, script: script)
    }
}