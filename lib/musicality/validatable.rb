# assumes that @checks is defined as an array of no-arg lambdas, each
# lambda raising an error (with useful msg) when check fails
module Validatable
  def errors
    if @errors.nil?
      self.validate
    end
    return @errors
  end
  
  def check_methods; []; end
  def validatables; []; end
  
  def validate
    @errors = []
    
    
    check_methods.each do |check_method|
      begin
        send(check_method)
      rescue StandardError => e
        @errors.push e
      end
    end
    
    validatables.each do |v|
      if v.respond_to?(:validate)
        @errors += v.validate
      end
    end
    
    return @errors
  end
  
  def valid?
    self.validate
    @errors.empty?
  end
  
  def invalid?
    !self.valid?
  end
end
