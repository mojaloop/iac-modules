#!/bin/sh

# Script to delete old Kubernetes jobs, retaining only the 5 most recent jobs per prefix
# Jobs must have timestamp suffix format: YYYY-MM-DD-HH-MM-SS
# Example: test-fxp-onboard-dfsp-2026-01-29-14-34-08

set -e

# Configuration
CLEAN_RETAIN_COUNT=${CLEAN_RETAIN_COUNT:-5}
CLEAN_NAMESPACE=${CLEAN_NAMESPACE:-mojaloop}
CLEAN_DRY_RUN=${CLEAN_DRY_RUN:-false}

# Function to extract job prefix (everything before the timestamp)
get_job_prefix() {
    job_name=$1
    # Remove timestamp pattern from the end: -YYYY-MM-DD-HH-MM-SS
    echo "$job_name" | sed -E 's/-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}$//'
}

# Function to validate timestamp suffix
has_timestamp_suffix() {
    job_name=$1
    echo "$job_name" | grep -qE -- 'onboard-dfsp-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}$'
}

# Get all jobs in namespace
echo "Fetching jobs from namespace: $CLEAN_NAMESPACE"
jobs=$(kubectl get jobs -n "$CLEAN_NAMESPACE" -o json | jq -r '.items[].metadata.name')

if [ -z "$jobs" ]; then
    echo "No jobs found in namespace $CLEAN_NAMESPACE"
    exit 0
fi

# Create temporary directory for grouping
tmpdir=$(mktemp -d -p /vault/secrets/tmp)
trap 'rm -rf "$tmpdir"' EXIT

# Group jobs by prefix (using filesystem instead of associative arrays)
for job in $jobs; do
    if has_timestamp_suffix "$job"; then
        prefix=$(get_job_prefix "$job")
        echo "$job" >> "$tmpdir/$prefix"
    else
        echo "Skipping job without timestamp suffix: $job"
    fi
done

# Process each job group
for prefix_file in "$tmpdir"/*; do
    [ -e "$prefix_file" ] || continue
    prefix=$(basename "$prefix_file")

    echo ""
    echo "Processing job group: $prefix"

    # Sort jobs by timestamp (descending - newest first)
    sorted_jobs=$(sort -r "$prefix_file")

    # Count jobs
    job_count=$(echo "$sorted_jobs" | wc -l)
    echo "Found $job_count jobs with prefix: $prefix"

    if [ "$job_count" -le "$CLEAN_RETAIN_COUNT" ]; then
        echo "Retaining all $job_count jobs (under limit of $CLEAN_RETAIN_COUNT)"
        continue
    fi

    # Skip the first CLEAN_RETAIN_COUNT jobs and delete the rest
    jobs_to_delete=$(echo "$sorted_jobs" | tail -n +"$((CLEAN_RETAIN_COUNT + 1))")
    delete_count=$(echo "$jobs_to_delete" | wc -l)

    echo "Retaining $CLEAN_RETAIN_COUNT newest jobs"
    echo "Deleting $delete_count old jobs"

    echo "$jobs_to_delete" | while IFS= read -r job_to_delete; do
        if [ "$CLEAN_DRY_RUN" = "true" ]; then
            echo "[DRY RUN] Would delete job: $job_to_delete"
        else
            echo "Deleting job: $job_to_delete"
            kubectl delete job "$job_to_delete" -n "$CLEAN_NAMESPACE"
        fi
    done
done
