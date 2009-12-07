class SourceObserver < MongoMapper::Observer
  
  observe Source
  
  def after_create(source)
    adjust_source_count(source, 1)
  end

  def after_destroy(source)
    adjust_source_count(source, -1)
  end
  
  def before_update(source)
    @previous_source = source.reload
  end

  def after_update(source)
    adjust_source_count(@previous_source, -1) if @previous_source
    adjust_source_count(source, 1)
  end
  
  protected
  
  def adjust_source_count(source, delta)
    org = source.organization
    if org
      if org.source_count
        org.source_count += delta
      else
        org.source_count = delta
      end
      org.save!
    end
  end
  
end

SourceObserver.instance
