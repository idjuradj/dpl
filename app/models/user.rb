class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  acts_as_voter
  has_many :links
  has_many :comments

  # korisnik mora da unese username, password i email
  # password se preskace u metodi password_required ako je twitter login u pitanju
  # devise radi zahtevanje emaila
  validates :username, :presence => true
  validates_uniqueness_of :username

  def self.from_omniauth(auth)

    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.username = auth.info.nickname
      user.name = auth.info.name
      user.avatar = auth.info.image
      user.about = auth.info.description
    end

  end

  def self.new_with_session(params, session)

    # vrsi se provera da li je prosledjena sesija sa podacima sa tvitera
    # ukoliko je to slucaj, prosledjuju se parametri sa sesije
    # u suprotnom se prepusta default ponasanje metode new_with_session 
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end 

  def password_required?

    # ukoliko se vrsi login sa tviterom, zaobilazi se zahtevanje
    # unosa lozinke, u suprotnom se koristi default ponasanje metode
    # provider se detektuje tako sto je to polje popunjeno imenom providera

    super && provider.blank?

  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  def increase_karma(count=1)
    update_attribute(:karma, karma + count)
  end

  def decrease_karma(count=1)
    update_attribute(:karma, karma - count)
  end

  def stories_posted
    Link.where(:user_id => self.id).count
  end

  def comments_posted
    Comment.where(:user_id => self.id).count
  end

  def stories_by_user
    self.links.last(5)
  end

  def comments_by_user
    self.comments.last(5)
  end

end