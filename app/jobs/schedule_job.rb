class ScheduleJob < ActiveJob::Base
  
  # so it will queue all this.
  queue_as :algorini
  self.queue_adapter = Rails.env.production? ? :delayed_job : :inline

  ##so we try to get this delayed shit working first
  ##then we can proceed.
  ##we currently log all exceptions to redis.
  ##so delayed job is done.
  ##but its not working properly
  rescue_from(StandardError) do |exception|
  	puts exception.message
   	puts exception.backtrace.join("\n")
  end
 
  ## expected array of arguments is: 
  ## this job is for creation of orders
  ## reallotments
  ## status blocking
  ## if it is for creating orders, the best options would be 
  ## to give the order id, and call a method on it, that does the 
  ## heavy lifting.
  ## on the order, the action will be schedule.
  ## an order could get cancelled,
  ## in that case the background job would have to unschedule it.
  ## if its a routine, then that also has an action attribute
  ## there is also reallotment.
  ## that will be called on employee.
  ## 0 => object_id
  ## 1 => object_class
  ## 2 => object_method_to_be_called_in_the_background_job/or some custom string argument.
  ## the object calls the schedule method on itself.
  def perform(args)
    Elasticsearch::Persistence.client.indices.refresh index: "frontend*"
    ## here you are saying Indicator.find
    ## and it is not being able to find the job.
    ## because it is using that document type.
    obj = args[1].constantize.find(args[0])
    obj.run_callbacks(:find)
    obj.do_background_job(args[2]) if obj.respond_to? "do_background_job"
  end

end