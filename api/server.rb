Handler = Proc.new do |req, res|

  res.status = 200
  res['Content-Type'] = 'text/text; charset=utf-8'
  res.body = "OK"
<<<<<<< HEAD
  # changes
=======

>>>>>>> c789a3f... refactoring
end
