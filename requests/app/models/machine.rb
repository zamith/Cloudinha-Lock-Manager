class Machine < ActiveRecord::Base

  # ==========================================================================
  # Relationships
  # ==========================================================================


  # ==========================================================================
  # Validations
  # ==========================================================================


  # ==========================================================================
  # Extra definitions
  # ==========================================================================


  # ==========================================================================
  # Instance Methods
  # ==========================================================================

  def alive?
    self.status == "Alive"
  end

  def free?
    self.user == "free"
  end

  # ==========================================================================
  # Class Methods
  # ==========================================================================

  class << self
    def lock(from,to,name)
      if from > to
        temp = from
        from = to
        to = temp
      end
    
      already_locked = []
      Machine.all(:conditions => ["id in (?)",(from..to)]).each do |machine|
        if machine.user != "free"
          already_locked << machine.id
        else
          machine.user = name
          machine.save
        end
      end
      return already_locked
    end

    def unlock(from,to)
      if from > to
        temp = from
        from = to
        to = temp
      end

      Machine.all(:conditions => ["id in (?)",(from..to)]).each do |machine|
          machine.user = "free"
          machine.save
      end
    end

  end

end
