@Library('surf-lib@version-3.0.0-SNAPSHOT') // https://bitbucket.org/surfstudio/jenkins-pipeline-lib/
import ru.surfstudio.ci.pipeline.ui_test.UiTestPipelineiOS

//init
def pipeline = new UiTestPipelineiOS(this)
pipeline.init()

//configuration
pipeline.sourceRepoUrl = "TODO add repo source code app"
pipeline.jiraProjectKey = "TODO add key project in jira"
pipeline.testBranch = "master" // branch with tests
pipeline.defaultTaskKey = "TODO add key test execution in jira" //task for run periodically
pipeline.testDeviceName = "iPhone 11"
pipeline.testOSVersion = "com.apple.CoreSimulator.SimRuntime.iOS-13-3"
pipeline.testiOSSDK = "iphonesimulator13.2"
pipeline.projectForBuild = "test"

//customization
pipeline.cronTimeTrigger = "01 04 * * *"
pipeline.notificationEnabled = false

//run
pipeline.run()