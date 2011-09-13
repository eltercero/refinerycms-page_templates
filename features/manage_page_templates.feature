@page_templates
Feature: Page Templates
  In order to have page_templates on my website
  As an administrator
  I want to manage page_templates

  Background:
    Given I am a logged in refinery user
    And I have no page_templates

  @page_templates-list @list
  Scenario: Page Templates List
   Given I have page_templates titled UniqueTitleOne, UniqueTitleTwo
   When I go to the list of page_templates
   Then I should see "UniqueTitleOne"
   And I should see "UniqueTitleTwo"

  @page_templates-valid @valid
  Scenario: Create Valid Page Template
    When I go to the list of page_templates
    And I follow "Add New Page Template"
    And I fill in "Name" with "This is a test of the first string field"
    And I press "Save"
    Then I should see "'This is a test of the first string field' was successfully added."
    And I should have 1 page_template

  @page_templates-invalid @invalid
  Scenario: Create Invalid Page Template (without name)
    When I go to the list of page_templates
    And I follow "Add New Page Template"
    And I press "Save"
    Then I should see "Name can't be blank"
    And I should have 0 page_templates

  @page_templates-edit @edit
  Scenario: Edit Existing Page Template
    Given I have page_templates titled "A name"
    When I go to the list of page_templates
    And I follow "Edit this page_template" within ".actions"
    Then I fill in "Name" with "A different name"
    And I press "Save"
    Then I should see "'A different name' was successfully updated."
    And I should be on the list of page_templates
    And I should not see "A name"

  @page_templates-duplicate @duplicate
  Scenario: Create Duplicate Page Template
    Given I only have page_templates titled UniqueTitleOne, UniqueTitleTwo
    When I go to the list of page_templates
    And I follow "Add New Page Template"
    And I fill in "Name" with "UniqueTitleTwo"
    And I press "Save"
    Then I should see "There were problems"
    And I should have 2 page_templates

  @page_templates-delete @delete
  Scenario: Delete Page Template
    Given I only have page_templates titled UniqueTitleOne
    When I go to the list of page_templates
    And I follow "Remove this page template forever"
    Then I should see "'UniqueTitleOne' was successfully removed."
    And I should have 0 page_templates
 