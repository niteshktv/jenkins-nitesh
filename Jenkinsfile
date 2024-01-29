import groovy.json.JsonSlurperClassic
    

pipeline {
    agent any
    
    environment {
        RUN_ARTIFACT_DIR = "tests/${env.BUILD_NUMBER}"
        SCRATCH_ORG_ALIAS = 'Org9'
        TEST_LEVEL = 'RunLocalTests'
        SFDC_HOST = env.SFDC_HOST_DH
        JWT_KEY_CRED_ID = env.JWT_CRED_ID_DH
        HUB_ORG = env.HUB_ORG_DH
        CONNECTED_APP_CONSUMER_KEY = env.CONNECTED_APP_CONSUMER_KEY_DH

        // println 'KEY IS'
        // println JWT_KEY_CRED_ID
        // println HUB_ORG
        // println SFDC_HOST
        // println CONNECTED_APP_CONSUMER_KEY
    }
    
    stages {
        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }
        
        stage('Deploy Code') {
            steps {
                script {
                    if (isUnix()) {
                        rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --client-id ${env.CONNECTED_APP_CONSUMER_KEY_DH} --username ${env.HUB_ORG_DH} --jwt-key-file ${env.JWT_CRED_ID_DH} --set-default-dev-hub --instanceurl ${env.SFDC_HOST_DH} --alias HubOrg"
                    } else {
                        rc = bat returnStatus: true, script: "sfdx force:auth:jwt:grant --client-id ${env.CONNECTED_APP_CONSUMER_KEY_DH} --username ${env.HUB_ORG_DH} --jwt-key-file \"${env.JWT_CRED_ID_DH}\" --set-default-dev-hub --instanceurl ${env.SFDC_HOST_DH} --alias HubOrg"
                    }
                    if (rc != 0) { error 'hub org authorization failed' }
                    println rc
                }
            }
        }
        
        stage('Create Test Scratch Org') {
            steps {
                script {
                    if (isUnix()) {
                        rmsg = sh returnStatus: true, script: "sf org create scratch --target-dev-hub HubOrg --set-default --definition-file config/project-scratch-def.json --alias ${SCRATCH_ORG_ALIAS} --wait 10 --duration-days 1"
                    } else {
                        rmsg = bat returnStatus: true, script: "sf org create scratch --target-dev-hub HubOrg --set-default --definition-file config/project-scratch-def.json --alias ${SCRATCH_ORG_ALIAS} --wait 30 --duration-days 1"
                        bat returnStatus: true, script: "sf config set target-org ${SCRATCH_ORG_ALIAS}"
                    }
                    if (rmsg != 0) { error 'Scratch Org creation failed' }
                    println('rmsg : ' + rmsg)
                }
            }
        }
        
        stage('Generate Username and Password') {
            steps {
                script {
                    if (isUnix()) {
                        rmsg = sh returnStatus: true, script : "sf org generate password --target-org ${SCRATCH_ORG_ALIAS} --length 20"
                    } else {
                        rmsg = bat returnStatus: true, script: "sf org generate password --target-org ${SCRATCH_ORG_ALIAS} --length 20"
                    }
                    if (rmsg != 0) { error 'Scratch Org username and password generation failed' }
                }
            }
        }
        
        stage('Display User') {
            steps {
                script {
                    if (isUnix()) {
                        rmsg = sh returnStatus: true, script : "sf org display user --target-org ${SCRATCH_ORG_ALIAS}"
                    } else {
                        rmsg = bat returnStatus: true, script: "sf org display user --target-org ${SCRATCH_ORG_ALIAS}"
                    }
                    if (rmsg != 0) { error 'Scratch Org display user failed' }
                }
            }
        }
        
        stage('Push To Test Scratch Org') {
            steps {
                script {
                    if (isUnix()) {
                        rmsg1 = sh returnStatus: true, script: "sf project deploy start --target-org ${SCRATCH_ORG_ALIAS}"
                    } else {
                        rmsg1 = bat returnStatus: true, script: "sf project deploy start --target-org ${SCRATCH_ORG_ALIAS}"
                    }
                    if (rmsg1 != 0) { error 'Scratch Org deployment failed' }
                }
            }
        }
        
        stage('Run Tests In Test Scratch Org') {
            steps {
                script {
                    if (isUnix()) {
                        rc = sh returnStatus: true, script: "sf apex run test --target-org ${SCRATCH_ORG_ALIAS} --wait 10 --result-format tap --code-coverage --test-level ${TEST_LEVEL}"
                    } else {
                        rc = bat returnStatus: true, script: "sf apex run test --target-org ${SCRATCH_ORG_ALIAS} --wait 10 --result-format tap --code-coverage --test-level ${TEST_LEVEL}"
                    }
                    if (rc != 0) { error 'Salesforce unit test run in test scratch org failed.' }
                }
            }
        }
    }
    
    post {
        always {
            script {
                bat returnStatus: true, script: "sf apex run --target-org ${SCRATCH_ORG_ALIAS} --file ~/GetContacts.cls"
            }
        }
    }
}

