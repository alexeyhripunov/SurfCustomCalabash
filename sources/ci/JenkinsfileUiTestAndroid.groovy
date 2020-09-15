@Library('surf-lib@version-3.0.0-SNAPSHOT') // https://bitbucket.org/surfstudio/jenkins-pipeline-lib/
import ru.surfstudio.ci.pipeline.ui_test.UiTestPipelineAndroid

//init
def pipeline = new UiTestPipelineAndroid(this)
pipeline.init()

//configuration
pipeline.sourceRepoUrl = "TODO add repo source code app"
pipeline.jiraProjectKey = "TODO add key project in jira"
pipeline.testBranch = "master" // branch with tests
pipeline.defaultTaskKey = "TODO add key test execution in jira" //task for run periodically
pipeline.projectForBuild = “TODO add name project for build in jenkins”


//customization
pipeline.cronTimeTrigger = "00 02 * * *"
pipeline.notificationEnabled = false
pipeline.buildGradleTask = "clean assembleQa"

//run
pipeline.run()