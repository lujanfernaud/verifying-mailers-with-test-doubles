require "spec_helper"
require "signup"

describe Signup do
  describe "#save" do
    it "creates an account with one user" do
      account = stub_created(Account)
      user    = stub_created(User)
      mailer  = stub_mailer_with(account, user)
      logger  = FakeLogger.new
      signup  = Signup.new(
        logger: logger,
        email: "user@example.com",
        account_name: "Example"
      )

      result = signup.save

      expect(Account).to have_received(:create!).with(name: "Example")
      expect(User).to have_received(:create!)
        .with(account: account, email: "user@example.com")
      expect(mailer).to have_received(:deliver)
      expect(logger.output)
        .to eq("[INFO] Sign up email sent with subject: #{mailer.subject}")
      expect(result).to be(true)
    end
  end

  def stub_created(model)
    double(model.name, name: "Example").tap do |instance|
      allow(model).to receive(:create!).and_return(instance)
    end
  end

  def stub_mailer_with(account, user)
    subject = "Your new #{account.name} account"

    double(SignupMailer.name, subject: subject).tap do |instance|
        allow(SignupMailer).to receive(:signup)
          .with(account: account, user: user)
          .and_return(instance)
        allow(instance).to receive(:deliver)
    end
  end
end

class FakeLogger
  attr_reader :output

  def info(mailer_subject)
    @output = "[INFO] Sign up email sent with subject: #{mailer_subject}"
  end
end
