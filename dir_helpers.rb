def require_dir(dir)
  subdir = File.expand_path(File.join(File.dirname(__FILE__), dir))
  Dir.glob("#{subdir}/*.rb").each do |f|
    require f
  end
end

def load_dir(dir, pattern)
  subdir = File.expand_path(File.join(File.dirname(__FILE__), dir))
  Dir.glob("#{subdir}/#{pattern}").each do |f|
    load f
  end
end
