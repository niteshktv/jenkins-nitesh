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
        stage('Deploye Code') {
            if (isUnix()) {
                rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --client-id ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwt-key-file ${jwt_key_file} --set-default-dev-hub --instanceurl ${SFDC_HOST} --alias myDevorg"
            }else{
                 rc = bat returnStatus: true, script: "sfdx force:auth:jwt:grant --client-id ${CONNECTED_APP_CONSUMER_KEY} --username ${HUB_ORG} --jwt-key-file \"${jwt_key_file}\" --set-default-dev-hub --instanceurl ${SFDC_HOST} --alias myDevorg"
                
            }
            if (rc != 0) { error 'hub org authorization failed' }

			println rc
			
			// need to pull out assigned username
			if (isUnix()) {
				rmsg = sh returnStdout: true, script: "sfdx force:source:deploy --manifest manifest/package.xml -u ${HUB_ORG}"
			}else{
			   rmsg = bat returnStdout: true, script: "sfdx force:source:deploy --manifest manifest/package.xml -u ${HUB_ORG}"
			}
			  
            printf rmsg
            println('Hello from a Job DSL script!')
            println(rmsg)
        }


        // //create scratch org
        // stage('Create Test Scratch Org') {
        //     if(isUnix()){
        //         rmsg = sh returnStdout: true, script: "sf org create scratch --target-dev-hub myDevorg --set-default --definition-file config/project-scratch-def.json --alias org4 --wait 10 --duration-days 1"
        //     }else{
        //         rmsg = bat returnStdout: true, script: "sf org create scratch --target-dev-hub myDevorg --set-default --definition-file config/project-scratch-def.json --alias org4 --wait 10 --duration-days 1"
        //     }

        //     println('rmsg : ' + rmsg)
            
        //     if (rmsg != 0) {
        //         error 'Salesforce test scratch org creation failed.'
        //     }

        //     println('rmsg : ' + rmsg)
        // }

        // // Deploy code to scratch org

        // stage('Push To Test Scratch Org') {
        //     if(isUnix()){
        //         rmsg1 = sh returnStdout: true, script: "sf project deploy start --target-org org4";
        //     }else{
        //         rmsg1 = bat returnStdout: true, script: "sf project deploy start --target-org org4"
        //     }

        //     if (rmsg1 != 0) {
        //     error 'Salesforce push to test scratch org failed.'
        //     }
        // }
    }
}