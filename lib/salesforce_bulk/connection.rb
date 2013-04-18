module SalesforceBulk
  class Connection
    CSV_OPTIONS = {
      col_sep: ',',
      quote_char: '"',
      force_quotes: true,
    }

    def initialize(username, password, api_version, sandbox)
      @username = username
      @password = password
      @api_version = api_version
      @sandbox = sandbox
      login
    end

    def login
      response = SalesforceBulk::Http.login(
        @sandbox,
        @username,
        @password,
        @api_version)

      @session_id = response[:session_id]
      @instance = response[:instance]
    end

    def create_job operation, sobject, external_field
      SalesforceBulk::Http.create_job(
        @instance,
        @session_id,
        operation,
        sobject,
        @api_version,
        external_field)[:id]
    end

    def close_job job_id
      SalesforceBulk::Http.close_job(
        @instance,
        @session_id,
        job_id,
        @api_version)[:id]
    end

    def add_query job_id, data_or_soql
      SalesforceBulk::Http.add_batch(
        @instance,
        @session_id,
        job_id,
        data_or_soql,
        @api_version)[:id]
    end

    def query_batch job_id, batch_id
      SalesforceBulk::Http.query_batch(
        @instance,
        @session_id,
        job_id,
        batch_id,
        @api_version,
      )
    end

    def query_batch_result_id job_id, batch_id
      SalesforceBulk::Http.query_batch_result_id(
        @instance,
        @session_id,
        job_id,
        batch_id,
        @api_version,
      )
    end

    def query_batch_result_data job_id, batch_id, result_id
      SalesforceBulk::Http.query_batch_result_data(
        @instance,
        @session_id,
        job_id,
        batch_id,
        result_id,
        @api_version,
      )
    end

    def add_batch job_id, records
      keys = records.first.keys

      rows = keys.to_csv(CSV_OPTIONS)
      records.each do |r|
        fields = []
        keys.each do |k|
          fields.push(r[k])
        end
        rows << fields.to_csv(CSV_OPTIONS)
      end

      SalesforceBulk::Http.add_batch(
        @instance,
        @session_id,
        job_id,
        rows,
        @api_version)[:id]
    end
  end
end