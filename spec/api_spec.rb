require 'HTTParty'

describe "The Todos API" do
posted_ids=[] #creating an array containing the IDs of all ToDos posted to the url by this test for clearup later
 
  it "should POST to Todos" do
    posted = HTTParty.post url('/todos'), query:{title: 'new toDO', due: Date.parse("1 Jan 2009")}
    posted_ids.push(posted['id'])
    expect(posted.message).to eq 'Created'
    expect(posted.code).to eq 201
  end

  it "should only POST if the necessary arguments have been supplied" do
    invalid_post = HTTParty.post url('/todos'), query:{title: 'new toDO'}
    expect(invalid_post.message).to eq 'Unprocessable Entity'
    expect(invalid_post.code).to eq 422
  end

  it "shouldn't be allowed to post to a specific todo" do
    posted = HTTParty.post url('/todos'), query:{title: 'good toDO', due: Date.parse("3 Jan 2009")}
    posted_ids.push posted['id']
    invalid_post = HTTParty.post url("/todos/#{posted['id']}"), query:{title: 'bad toDO', due: Date.parse("12 Jan 2019")}
    expect(invalid_post.message).to eq 'Method Not Allowed'
    expect(invalid_post.code).to eq 405
  end

  it "should DELETE a Todo" do
    posted = HTTParty.post url('/todos'), query:{title: 'delete me bitch', due: Date.today}
    del = HTTParty.delete url("/todos/#{posted['id']}")
    expect(del.message).to eq 'No Content'
    expect(del.code).to eq 204
  end

  it "should not be able to delete the entire collection" do
    del = HTTParty.delete url('/todos')
    expect(del.message).to eq 'Method Not Allowed'
    expect(del.code).to eq 405
  end

  it "should return 200 for successful GET requests on the collection" do
    get_req = HTTParty.get url('/todos')
    expect(get_req.code).to eq 200
    expect(get_req.message).to eq 'OK'
  end

  it "should GET a specific Todo by its ID" do
    posted = HTTParty.post url('/todos'), query:{title: 'find me!', due: Date.parse("1 Jan 2009")}
    posted_ids.push posted['id']
    get_req = HTTParty.get url("/todos/#{posted['id']}")
    expect(get_req.code).to eq 200
    expect(get_req.message).to eq 'OK'
    expect(get_req["title"]).to eq "find me!"
  end

  it "should be able to patch an existing Todo's title" do
    posted = HTTParty.post url('/todos'), query:{title: 'patch me!', due: Date.parse("21 Nov 2016")}
    posted_ids.push posted['id']
    patchtitle = HTTParty.patch url("/todos/#{posted['id']}"), query:{title: 'patched'}
    patchdate = HTTParty.patch url("/todos/#{posted['id']}"), query:{due: Date.parse("02 Feb 2020")}
    get_req = HTTParty.get url("/todos/#{posted['id']}")
    expect(get_req['title']).to eq "patched"
    expect(get_req['due']).to eq "2020-02-02"
    expect(get_req.code).to eq 200
    expect(get_req.message).to eq 'OK'
  end

  it "shouldn't be able to patch an entire collection" do
    patch = HTTParty.patch url('/todos'), query:{title: 'patched', due: Date.parse("02 Feb 2020")}
    expect(patch.code).to eq 405
    expect(patch.message).to eq 'Method Not Allowed'
  end

  it "it should be able to run PUT requests" do
    posted = HTTParty.post url('/todos'), query:{title: 'put meh!', due: Date.today}
    posted_ids.push posted['id']
    put = HTTParty.put url("/todos/#{posted['id']}"), query:{title: 'get putted', due: Date.parse("20 April 2420")}
    get = HTTParty.get url("/todos/#{posted['id']}")
    expect(get['title']).to eq 'get putted'
    expect(get.code).to eq 200
    expect(get.message).to eq "OK"
  end

  it "shouldn't be able to PUT to the collection" do
    put = HTTParty.put url('/todos'), query:{title: 'invalid put', due: Date.parse("20 April 2420")}
    expect(put.code).to eq 405
    expect(put.message).to eq 'Method Not Allowed'
  end

  def teardown
    posted_ids.each do |id|
      del = HTTParty.delete url("/todos/#{id}")
      expect(del.message).to eq 'No Content'
      expect(del.code).to eq 204
    end
  end
end
