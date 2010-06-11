class Bacon::Context
  include RR::Adapters::RRMethods
  RR.trim_backtrace = true
  alias_method :old_it, :it
  def it(description)
    old_it(description) do
      begin
        # Add at least one requirement to ensure mock-only tests don't fail
        Bacon::Counter[:requirements] += 1
        yield
        Bacon::Counter[:requirements] -= 1 if RR.double_injections.size.zero?
        RR.verify
      rescue RR::Errors::RRError=>e
        raise Bacon::Error.new(:failed, e.message)
      ensure
        RR.reset
      end
    end
  end
end
