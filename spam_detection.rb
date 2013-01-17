#!/usr/bin/env ruby

#	Lesson: Machine Learning and Knowledge Discovery
#	Author: Pappas Nikolaos
#	A/M: icsm09031
#	Email: nik0spapp@gmail.com

require 'rubygems' 
require 'bayes.rb'

# Handle the user input
if ARGV.length == 0
  puts "Please enter corpora name in order to load files!"
  puts "Availiable: pu1, pu2, pu3, pua"
  puts "e.g:"
  puts "ruby spam_detection.rb <corpora_name>"
  exit
else
  # Set the global path
  path = "corpora/#{ARGV[0]}/"
end

# Initialize structures needed for 10-fold cross
k, index, average_recall, average_precision = 10, 1, 0, 0
puts "Running 10-fold cross validation..." 

k.times do
  # Initialize structures
  training_emails, test_emails, i = {:spam => [], :legitimate => []}, [], 1
  training_folder = ""
  total_identified_as_spam, correctly_identified_as_spam =  0, 0
  folders = Dir.new(path).entries
  
  # Create the Bayes classifier
  classifier = Classifier::Bayes.new('Legitimate', 'Spam')
  
  folders.sort_by { |val| val.gsub("part","").to_i }.each do |folder|    
    if folder =~ /[part\d]/
       # Choose one set of 10 (that has not previously been selected) 
       # for test and merge the rest for training i.e serially
       if index == i 
          test_emails = classifier.load_emails(path + folder + "/")
          training_folder = folder
       else 
          current_emails  = classifier.load_emails(path + folder + "/")
          training_emails[:spam] += current_emails[:spam]
          training_emails[:legitimate] += current_emails[:legitimate]
       end
       i += 1
    end
  end
  
  # Train the classifier
  training_emails[:legitimate].each {|legit| classifier.train('legitimate', legit)}
  training_emails[:spam].each {|spam| classifier.train('spam', spam)}
  
  # Classify test emails
  test_emails[:legitimate].each do |email|
     #puts classifier.classify(email)
     total_identified_as_spam += 1 if classifier.classify(email) == "Spam"
  end
  test_emails[:spam].each do |email|
     #puts classifier.classify(email)
     if classifier.classify(email) == "Spam"
       total_identified_as_spam += 1 
       correctly_identified_as_spam += 1
     end
  end
  
  train_count = training_emails[:legitimate].length + training_emails[:spam].length
  test_count = test_emails[:legitimate].length + test_emails[:spam].length
  puts "[ITERATION:] #{index}" 
  puts "===================================="
  puts "Training emails: #{train_count}" 
  puts "Test emails: #{test_count}"
  puts "Test folder: #{training_folder}" 
  puts "Correctly identified as spam: #{correctly_identified_as_spam}"
  puts "Total identified as spam: #{total_identified_as_spam}"
  puts "Total spam: #{test_emails[:spam].length}"
  puts "SPAM RECALL: #{correctly_identified_as_spam/test_emails[:spam].length.to_f}"
  puts "SPAM PRECISION: #{correctly_identified_as_spam/total_identified_as_spam.to_f}"
  average_recall += correctly_identified_as_spam/test_emails[:spam].length.to_f
  average_precision += correctly_identified_as_spam/total_identified_as_spam.to_f
  puts "\n"
  # Print the classifier itself
  #p classifier
	index += 1
end

puts "-------------------------------------\n\n" 
puts "COLLECTION: #{ARGV[0]}"
puts "AVG SPAM RECALL: #{(average_recall/k)*100}%"
puts "AVG SPAM PRECISION: #{(average_precision/k)*100}%"
puts "\n-------------------------------------\n"
