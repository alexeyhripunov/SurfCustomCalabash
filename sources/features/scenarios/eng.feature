
#all your scenarios should be here
Feature:
	@android @reinstall
	Scenario: Test
		When I start the application
		And I use gmail for authorization

