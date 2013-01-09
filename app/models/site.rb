#coding: utf-8
class Site < ActiveRecord::Base
  Page_Size=10
  MAX_GUEST_KEYWORDS=30
  validates_presence_of :name,:keywords
  validates_length_of :label,:maximum=>15

  has_many :site_results,:dependent => :destroy
  belongs_to :user
  attr_accessible :keywords, :name,:label,:search_engines
  validate :validation_keywords_size

  def search_rank
    if search_engines.nil? || search_engines.blank? 
      return
    end
    search_engines.split(',').each do |search_engine|
      #puts "#{search_engine}-------------------------"

      next if search_engine.blank?

      SiteResult.transaction do
        site_result=site_results.find(:first,  \
        :conditions =>["date(created_at)=:today and search_engine=:search_engine", \
        {:search_engine=>search_engine,:today=>Date.today}])
        #puts site_result
        if site_result.nil?   
          #puts  "new==============================="
          site_result=SiteResult.new
          site_result.site=self
          site_result.search_engine=search_engine
          site_result.save
        else
          logger.info "today has searched:#{name}-#{search_engine}"
        end

        keywords.split.each do |keyword|
          result=site_result.search_results.find_by_keyword(keyword)
          if result.nil?
            #puts  "new==============================="
            result=SearchResult.new
            result.site_result=site_result
            result.keyword=keyword
            result.save
            result.search_rank        
          else
            logger.info "today has searched:#{keyword}"
          end
        end

      end
    end
  end

  def all_rank_dates(page=1)
     site_results
        .select("date(created_at) as created_day")
        .order("date(created_at) desc") 
        .uniq.limit(Page_Size).offset((page-1)*Page_Size)
  end

  def has_prev(page=1)
    page>1
  end

  def has_next(page=1)
    total_rank_dates > page*Page_Size
  end

  def last_rank_date(page=1)
      result=site_results
        .select("date(created_at) as created_day")
        .order("date(created_at) desc")
        .uniq
        .offset((page-1)*Page_Size)
        .first
      return result.nil? ? nil: result.created_day 
  end

  def get_rank_result_by_engine_and_day(search_engine,date)
      site_results
      .includes(:search_results)
      .find(:first,:conditions=>["date(site_results.created_at)=? and search_engine=?",date,search_engine])
  end

  def self.query_by_name(name)
    q = "%#{name}%"
    where("name like ?", q).order("name asc")
  end 

  def total_rank_dates
    site_results.order("created_at desc") 
        .select("distinct date(created_at)").size
  end

  def xls_by_date(date)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet = book.create_worksheet :name => "rank" 
    row_index=set_xls_header(sheet)

    baidu_result=get_rank_result_by_engine_and_day(SearchEngine::BAIDU,date)
    google_result=get_rank_result_by_engine_and_day(SearchEngine::GOOGLE,date)

    keywords.split.each_with_index do |keyword,index|
      baidu_keyword_rank=baidu_result.nil? ? nil : baidu_result.get_rank_by_keyword(keyword)
      google_keyword_rank=google_result.nil? ? nil : google_result.get_rank_by_keyword(keyword)
      sheet[row_index,0]=index
      sheet[row_index,1]=keyword
      sheet[row_index,2]=case baidu_keyword_rank.status
                                  when RankStatus::SUCCESS then baidu_keyword_rank.rank.nil? ? "-" : "#{baidu_keyword_rank.rank}"
                                  else ""
                                end
      sheet[row_index,3]=case google_keyword_rank.status
                                  when RankStatus::SUCCESS then google_keyword_rank.rank.nil? ? "-" : "#{google_keyword_rank.rank}"
                                  else ""
                                end
      row_index+=1
    end
    book.write xls_report  
    xls_report.string
  end

private
  
  def set_xls_header(sheet)
    row_index=0
    unless label.nil?
      bold_heading = Spreadsheet::Format.new(:weight => :bold, :size => 14, :align => :merge)
      header_row=sheet.row(row_index)
      3.times do |i|  
        header_row.set_format(i,bold_heading)  
      end 
      header_row[0]=label    
      row_index+=1 
    end

    sheet[row_index,0]='序号'
    sheet[row_index,1]='关键字'
    sheet[row_index,2]='百度排名'
    sheet[row_index,3]='Google排名'

    row_index+=1 
  end

  def validation_keywords_size
    errors[:keywords] << "关键词不能超过30个" if !user and keywords.split.size>MAX_GUEST_KEYWORDS
  end
end
