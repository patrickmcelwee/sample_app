require 'spec_helper'

describe User do

  before(:each) do
    @attr= {  :name => "Example User", :email => "user@example.com", 
              :password => "some_password", 
              :password_confirmation => "some_password" }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should require an email" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = 'a' * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end
  
  it "should accept valid email address" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    #Put a user with a given email address into the database.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "password validations" do
    
   it "should reject a user with no password" do
     User.new(@attr.merge(:password => "", :password_confirmation => "")).
     should_not be_valid
   end
  
   it "should require a matching password confirmation" do
     User.new(@attr.merge(:password_confirmation => "other_password")).
       should_not be_valid
   end

   it "should reject short passwords" do
     User.new(@attr.merge(:password => "short", 
                          :password_confirmation => "short")).
                          should_not be_valid
   end

   it "should reject long passwords" do
     long = "a" * 41
     hash = {:password => long, :password_confirmation => long }
     User.new(@attr.merge(hash)).should_not be_valid
   end
   
  end

  describe "password encryption" do

   before(:each) do
     @user = User.create!(@attr)
   end

   it "should recognize encrypted_password attribute" do
     @user.should respond_to :encrypted_password
   end

   it "should set the encrypted password" do
     @user.encrypted_password.should_not be_blank
   end

   describe "has_password? method" do

     it "should be true if the passwords match" do
       @user.has_password?(@attr[:password]).should be_true
     end

     it "should be false if the passwords do not match" do
       @user.has_password?("wrong_password").should be_false
       # Annoyingly passes as nil if has_password? method undefined
       @user.has_password?("wrong_password").should_not be_nil
     end
   end
  
    describe "authenticate method" do

     it "should return nil when the password is incorrect" do
       User.authenticate(@attr[:email], "invalid").should be_nil
     end

     it "should return nil when email matches no existing users" do
       User.authenticate("no_user@example.com", @attr[:password]).should be_nil
     end

     it "should return user object when email/password match" do
       User.authenticate(@attr[:email], @attr[:password]).should == @user
     end
    end
  end
end


# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#

