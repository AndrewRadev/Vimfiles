Feature: Block indenting

  Scenario: "do" blocks
    Given Vim is running
    And my ruby indent is loaded
    And I'm editing a file named "example.rb" with the following contents:
      """
      [1, 2, 3].each do |n|
      puts n
      end
      """
    When I reindent the file
    Then the file "example.rb" should contain the following text:
      """
      [1, 2, 3].each do |n|
        puts n
      end
      """
