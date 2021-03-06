@api
Feature: sharing
	Background:
		Given using API version "1"
		And using old DAV path

	Scenario: User is not allowed to reshare file
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user0" has created a share with settings
			| path        | /textfile0.txt |
			| shareType   | 0              |
			| shareWith   | user1          |
			| permissions | 8              |
		When user "user1" creates a share using the API with settings
			| path        | /textfile0 (2).txt |
			| shareType   | 0                  |
			| shareWith   | user2              |
			| permissions | 31                 |
		Then the OCS status code should be "404"
		And the HTTP status code should be "200"

	Scenario: User is not allowed to reshare file with more permissions
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user0" has created a share with settings
			| path        | /textfile0.txt |
			| shareType   | 0              |
			| shareWith   | user1          |
			| permissions | 16             |
		When user "user1" creates a share using the API with settings
			| path        | /textfile0 (2).txt |
			| shareType   | 0                  |
			| shareWith   | user2              |
			| permissions | 31                 |
		Then the OCS status code should be "404"
		And the HTTP status code should be "200"

	Scenario: Do not allow reshare to exceed permissions
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user0" has created a folder "/TMP"
		And user "user0" has created a share with settings
			| path        | /TMP  |
			| shareType   | 0     |
			| shareWith   | user1 |
			| permissions | 21    |
		And as user "user1"
		And the user has created a share with settings
			| path        | /TMP  |
			| shareType   | 0     |
			| shareWith   | user2 |
			| permissions | 21    |
		When the user updates the last share using the API with
			| permissions | 31 |
		Then the OCS status code should be "404"

	Scenario: Reshared files can be still accessed if a user in the middle removes it.
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user3" has been created
		And user "user0" has shared file "textfile0.txt" with user "user1"
		And user "user1" has moved file "/textfile0 (2).txt" to "/textfile0_shared.txt"
		And user "user1" has shared file "textfile0_shared.txt" with user "user2"
		And user "user2" has shared file "textfile0_shared.txt" with user "user3"
		When user "user1" deletes file "/textfile0_shared.txt" using the API
		And user "user3" downloads file "/textfile0_shared.txt" with range "bytes=1-7" using the API
		Then the downloaded content should be "wnCloud"

	Scenario: resharing using a public link with read only permissions is not allowed
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/test"
		And user "user0" has shared folder "/test" with user "user1" with permissions 1
		When user "user1" creates a share using the API with settings
			| path         | /test |
			| shareType    | 3     |
			| publicUpload | false |
		Then the OCS status code should be "404"
		And the HTTP status code should be "200"

	Scenario: resharing using a public link with read and write permissions only is not allowed
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/test"
		And user "user0" has shared folder "/test" with user "user1" with permissions 15
		When user "user1" creates a share using the API with settings
			| path         | /test |
			| shareType    | 3     |
			| publicUpload | false |
		Then the OCS status code should be "404"
		And the HTTP status code should be "200"

	Scenario: resharing a file is not allowed when allow resharing has been disabled
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user0" has created a share with settings
			| path        | /textfile0.txt |
			| shareType   | 0              |
			| shareWith   | user1          |
			| permissions | 31             |
		And parameter "shareapi_allow_resharing" of app "core" has been set to "no"
		When user "user1" creates a share using the API with settings
			| path        | /textfile0 (2).txt |
			| shareType   | 0                  |
			| shareWith   | user2              |
			| permissions | 31                 |
		Then the OCS status code should be "404"
		And as "user2" the file "/textfile0 (2).txt" should not exist
