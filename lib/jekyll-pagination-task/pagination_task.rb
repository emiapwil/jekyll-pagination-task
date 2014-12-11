module Jekyll
  module PaginationTask

    class PaginationFilter
      def initialize(site, pager) end

      def satisfy?(page)
        false
      end
    end

    class DefaultPaginationFilter < PaginationFilter
      
      def initialize(site, pager)
        @filters = []
        conditions = pager["pagination_filter"] || []
        conditions.each do |condition|
          name = condition[0]
          relation = condition[1]
          if !respond_to?("check_#{relation}")
            Jekyll.logger.warn "Decteced unsupported action " + attr_action
                                + " in pager file " + pager.url

            next
          end
          parameters = condition[2]
          @filters << { "name" => name, "relation" => relation, "parameters" => parameters }
        end
      end

      def check_all(parameters, attr)
        return false if attr.nil?
        parameters.each { |parameter| return false if !attr.include?(parameter) }
        true
      end

      def check_any(parameters, attr)
        return false if attr.nil?
        parameters.each { |parameter| return true if attr.include?(parameter) }
        false
      end

      def check_only(parameters, attr)
        return true if attr.nil?
        attr.each { |attribute| return false if !parameters.include?(attribute) }
        true
      end

      def check_none(parameters, attr)
        return true if attr.nil?
        parameters.each { |parameter| return false if attr.include?(parameter) }
        true
      end

      def satisfy?(post)
        @filters.each do |filter|
          relation = filter["relation"]
          parameters = filter["parameters"]
          attr = post[filter["name"]]
          checker = method("check_#{relation}")
          return false if !checker.call(parameters, attr)
        end
        true
      end
    end

    class PaginationTask < Generator
      # This generator is safe from arbitrary code execution.
      safe true

      # This generator should be passive with regard to its execution
      priority :lowest

      # Determine if pagination task is enabled
      # 
      # site - the Jekyll::Site object
      #
      # Returns true if pagination_task is enabled, false otherwise
      def self.enabled?(site)
        !site.config['pagination_task'].nil? && (site.pages.size > 0)
      end

      # Generate paginated pages if necessary.
      #
      # site - The Site.
      #
      # Returns nothing.
      def generate(site)
        if PaginationTask.enabled?(site)
          if pagers = candidate_pagers(site)
            pagers.each { |pager| site.pages.delete(pager) } 
            pagers.each { |pager| paginate(site, pager) }
          end
        end
      end

      # Get the filter
      #
      # site - the Jekyll::Site object
      #
      # return - the instance of the filter
      def get_filter(site, pager)
        page_filter_class = pager['filter_class']
        site_filter_class = site.config['pagination_task']['filter_class']
        class_name = page_filter_class || site_filter_class

        if class_name.nil? || !Object.const_defined?(class_name)
          DefaultPaginationFilter.new(site, pager)
        else
          Object.const_get(class_name).new(site, pager)
        end
      end

      def create_pager(site, template, pager)
        instance = template.dup
        instance.pager = pager
        instance.basename = "index"
        instance.data['paginated'] = true
        instance.dir = PTPager.paginate_path(site, template, pager.page)

        instance
      end

      # Paginates the blog's pages.
      # 
      # site - The Site.
      # template - The pager template that defines a pagination.
      #
      def paginate(site, template)
        all_pages = site.pages.select{ | page | !page['paginated'] }
        filter = get_filter(site, template)
        
        if filter.nil?
          Jekyll.logger.warn "Failed to create filter for page " + pager.url
          return
        end
        all_pages = all_pages.select{ | page | filter.satisfy?(page) }
        
        page_per_pager = template['page_per_pager']
        page_per_pager = page_per_pager || site.config['pagination_task']['page_per_pager']
        page_per_pager = page_per_pager || 7

        npages = Paginate::Pager.calculate_pages(all_pages, page_per_pager.to_i)
        (1..npages).each do |num_page|
          pager = PTPager.new(site, template, num_page, all_pages, npages)
          site.pages << create_pager(site, template, pager)
        end
      end

      # Public: Find the Jekyll::Page which will act as the pager template
      #
      # site - the Jekyll::Site object
      #
      # Returns the Jekyll::Page which will act as the pager template
      def candidate_pagers(site)
        site.pages.select { |page| (page['paginate'] || false ) === true }
      end
    end
  end

  class PTPager < Paginate::Pager

    # Get the path for the generated pagers
    #
    # site - the Jekyll::Site object
    # pager - the template for the pager
    def self.paginate_path(site, pager, page_num)
      return nil if page_num.nil?
      format = pager['pagination_format']
      format = format || site.config['pagination_task']['format']
      dir = pager.dir
      name = File.basename(pager.name, File.extname(pager.name))
      format = format.sub(':dir', dir)
      format = format.sub(':name', name)
      format = format.sub(':num', page_num.to_s)
      format = page_num > 1 ? format.sub(':Num', page_num.to_s) : format.sub(':Num', '')
      ensure_leading_slash(format)
    end

    # Initialize a new PTPager.
    #
    # site     - the Jekyll::Site object
    # pager    - the pager template page
    # current  - The Integer page number.
    # all_posts - The Array of all the site's Posts.
    # num_pages - The Integer number of pages or nil if you'd like the number
    #             of pages calculated.
    def initialize(site, pager, current, all_posts, num_pages = nil)
      super(site, current, all_posts, num_pages)
      @previous_path = PTPager.paginate_path(site, pager, @previous_page)
      @next_page_path = PTPager.paginate_path(site, pager, @next_page)
    end
  end
end
