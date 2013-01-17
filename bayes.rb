#!/usr/bin/env ruby

#	Lesson: Machine Learning and Knowledge Discovery
#	Author: Pappas Nikolaos
#	A/M: icsm09031
#	Email: nik0spapp@gmail.com


module Classifier 
  
class Bayes  
	
	# The class can be initialized with one or more categories
	def initialize(*categories)
		@categories = Hash.new	 
		categories.each {|cat| @categories[cat.capitalize.intern] = Hash.new}
		@total_words = 0
		@total_email = 0
		@vocabulary = {}
	end
 
	# Training method for all categories specified during class initialization
	# e.g:
	#     b = Classifier::Bayes.new 'Legitimate', 'Spam'
	#     b.train("legitimate", "This text")
	def train(category, text)
		category = category.capitalize.intern
		@categories[category][:total_email] ||= 0
		@categories[category][:total_email] += 1
		@total_email += 1
		text.split(" ").each do |word|    
			@categories[category][word] ||= 0
			@categories[category][word] += 1
			@vocabulary[word] = true
			@total_words += 1
		end
	end
 	 
	# Returns the scores in each category for the provided email based on the 
	# formula vj∈V P(vj) Πai∈x P(ai|vj). 
	# e.g:
	#   logP(legit|msg) = logP(legit) + logP(w1|legit) + ... + logP(wn|legit) 
	#   logP(spam|msg) = logP(spam) + logP(w1|spam) + ... + logP(wn|spam) 
	def classifications(email)
	  score = Hash.new
	  @categories.each do |category, category_words| 
		cat_total_email = @categories[category][:total_email] 
		score[category.to_s] = Math.log(cat_total_email / @total_email.to_f) # P(vj)
		total = category_words.values.inject(0) {|sum, freq| sum+freq}
		email.split(" ").each do |word|
		  word_counter = category_words.has_key?(word) ? category_words[word] : 0.1
		  p_w_vj = (word_counter)/(total + @vocabulary.length).to_f
		  score[category.to_s] += Math.log(p_w_vj) #P (ai|vj)
		end
	  end
	  return score
	end

	# Returns the classification of the provded email based on the formula
	# vNB = argmax vj∈V P(vj) Πai∈x P(ai|vj)
	def classify(email)
	  ordered = classifications(email).sort_by { |val| -val[1] }
		max = ordered[0][0]
		return max 
	end

	# Loads email from a specific directory and distincts the spam from
	# the legitimate emails.
	def load_emails(path) 
          filenames = Dir.new(path).entries
          spam_emails = []
          legitimate_emails = [] 
          filenames.each do |file|
            file_path = path + file 
            if (file != "." and file != "..") and FileTest::exist?(file_path)
			  file_lines = IO.readlines(file_path)
              email = file_lines.join("").gsub("Subject: ","").gsub("\n"," ")
              if file_path.include?("spmsg")
                spam_emails << email
              elsif file_path.include?("legit")
                legitimate_emails << email
              end
            end
          end
          return {:spam => spam_emails, :legitimate => legitimate_emails}
	end
end

end
