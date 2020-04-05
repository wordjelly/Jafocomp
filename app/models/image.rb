require 'elasticsearch/persistence/model'

class Image

  include Elasticsearch::Persistence::Model
  #include Concerns::FormConcern
  #include Concerns::TimestampsConcern
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Dirty

  index_name "pathofast-images"
  ## cloudinary link to show android app that signs request
  ## https://github.com/cloudinary/cloudinary_android/tree/master/sample-signed

  #include Mongoid::Document
  #include Auth::Concerns::OwnerConcern

  ## now what about transformations ?

  ###########################################################
  ##
  ##
  ##
  ## CLASS METHODS
  ##
  ##
  ## 
  ###########################################################
  ## the parent id is the id of the object in which the image is uploaded.
  ## it need not exist. but has to be a valid bson object id.
  def self.permitted_params
    [{:image => [:_id,:parent_id,:local_file_path, {:tags => []}, :parent_class,:active,:timestamp,:public_id,:custom_coordinates]},:id,:local_file_path,{:tags => []}]
  end

  ## first and foremost.
  ## what about giving that permission.
  ## do the pulsate and finish it.
  ## then check local item group.

  ###########################################################
  ##
  ##
  ##
  ## ATTRIBUTES
  ##
  ##
  ##
  ###########################################################  
  attribute :parent_id, String, mapping: {type: 'keyword'}
  attribute :parent_class, String, mapping: {type: 'keyword'}
  attribute :active, Boolean
  attribute :custom_coordinates, String, mapping: {type: 'keyword'}

  ## when we want to upload a local file .
  attribute :local_file_path, String, mapping: {type: 'keyword'}
  ## make this image searchable, give it some tags.
  ## these are used by other objects to show this image.
  attribute :tags, Array, mapping: {type: 'keyword'}


  attr_accessor :signed_request
  attr_accessor :timestamp
  attr_accessor :public_id
  
  ##########################################################
  ##
  ##
  ## DIRTY TRACKING.
  ##
  ##
  ###########################################################
  define_attribute_methods :local_file_path
  define_attribute_methods :parent_id
  
  def new_record?
    begin
      response = self.class.gateway.client.get :id => self.id.to_s, :index => self.class.index_name, :type => self.class.document_type
      false
    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
      true
    rescue Exception => e
      ## log 
      false
    end
  end

  def local_file_path
    @local_file_path
  end

  def local_file_path=(val)
    local_file_path_will_change! unless val == @local_file_path
    @local_file_path = val
  end

  def parent_id
    @parent_id
  end

  def parent_id=(val)
    parent_id_will_change! unless val == @parent_id
    @parent_id = val
  end

  def save
    save_result = super
    changes_applied
    save_result
  end

  ###########################################################
  ##
  ##
  ## VALIDATIONS
  ##
  ##
  ###########################################################
  validates :parent_id, presence: true, :if => Proc.new{|c| c.local_file_path.blank? }
  validates :parent_class, presence: true, :if => Proc.new{|c| c.local_file_path.blank? }
  validates :timestamp, numericality: { only_integer: true, greater_than_or_equal_to: Time.now.to_i - 30 }, if: Proc.new{|c| c.new_record?}
  validate :public_id_equals_id, if: Proc.new{|c| (c.new_record?) && (c.local_file_path.blank?)}
  validate :parent_object_exists, :if => Proc.new{|c| c.local_file_path.blank? }

  ###########################################################
  ##
  ##
  ## CALLBACKS
  ##
  ##
  ###########################################################
  before_validation do |document|
    puts "came to before validation."
    if document.local_file_path_changed?
      puts "local file path cahnged."
      unless document.local_file_path.blank?
        document.timestamp = Time.now.to_i
        document.upload_local_file
      end
    end
  end

  def upload_local_file
    if ((self.tags.blank? || self.tags.size > 1))
      self.public_id ||= SecureRandom.hex(10)
    else
      self.public_id = self.tags[0]
    end
    puts "came to upload the file:"
    puts "id was: #{self.id.to_s}, public id is: #{self.public_id}"
    self.id ||= self.public_id

    ## now delete if it already exists.

    response = Cloudinary::Uploader.destroy(self.public_id)
    
    puts "delete if already exists response is #{response}"

    response = Cloudinary::Uploader.upload(File.open(self.local_file_path), :public_id => public_id, :upload_preset => "report_pdf_files")
  
    puts "upload response is: #{response}"
  
    secure_url = response["secure_url"]
  
  end


  after_save do |document|
    document.signed_request = get_signed_request
  end

  ## this should destroy the image.
  ## what if you create a upload by providing a local image url.
  ## and just want to upload that
  ## like a local file path.
  ## it accepts
  ## then simply loads that -> and saves it.
  ## and we have something like tags
  ## and we search for images for that.
  before_destroy do |document|
    puts "triggered before destroy-----------"
    Cloudinary::Uploader.destroy(document.id.to_s)
  end

  ###########################################################
  ##
  ##
  ## CUSTOM VALIDATION DEFS.
  ##
  ##
  ###########################################################
  def public_id_equals_id
    self.errors.add(:public_id, "the public id and object id are not equal") if (self.id.to_s != self.public_id)
  end

  ## ensures that images can only be added to objects, if the object already has been saved.
  def parent_object_exists
    begin
      self.parent_class.constantize.find(self.parent_id)
    rescue
      self.errors.add(:parent_id,"the #{self.parent_class} does not exist, Create it before trying to add an image to it")
    end
  end

  ############################################################
  ##
  ##
  ## OTHER CUSTOM DEFS.
  ##
  ##
  ############################################################
  def get_signed_request
    ## these should be merged only if they exist.
    params_to_sign = {:public_id => self.id.to_s,:timestamp=> self.timestamp, :callback => "http://widget.cloudinary.com/cloudinary_cors.html"}
    params_to_sign.merge!({:custom_coordinates => self.custom_coordinates}) unless self.custom_coordinates.blank?
    Cloudinary::Utils.sign_request(params_to_sign, :options=>{:api_key=>Cloudinary.config.api_key, :api_secret=>Cloudinary.config.api_secret})
  end

  # if this can get it.
  # we will get a public id.

  ## rendered in create, in the authenticated_controller.
  def text_representation
    self.signed_request[:signature].to_s
  end

  def get_url
    if self.custom_coordinates
      Cloudinary::Utils.cloudinary_url self.id.to_s, gravity: "custom", crop: "crop", sign_url: true
    else
      Cloudinary::Utils.cloudinary_url self.id.to_s, sign_url: true
    end
  end

end
