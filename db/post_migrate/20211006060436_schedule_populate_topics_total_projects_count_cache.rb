# frozen_string_literal: true

class SchedulePopulateTopicsTotalProjectsCountCache < Gitlab::Database::Migration[1.0]
  MIGRATION = 'PopulateTopicsTotalProjectsCountCache'
  BATCH_SIZE = 10_000
  DELAY_INTERVAL = 2.minutes

  disable_ddl_transaction!

  def up
    queue_background_migration_jobs_by_range_at_intervals(
      define_batchable_model('topics'),
      MIGRATION,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE,
      track_jobs: true
    )
  end

  def down
    # no-op
  end
end
