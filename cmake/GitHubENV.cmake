# Write some temp files to make GitHub Actions / packaging easy

if ((DEFINED ENV{CI}))
    set (env_file "${PROJECT_SOURCE_DIR}/.env")
    message ("Writing ENV file for CI: ${env_file}")

    # the first call truncates, the rest append
    file(WRITE  env_file "${PROJECT_NAME}\\n")
    file(APPEND env_file "${PRODUCT_NAME}\\n")
    file(APPEND env_file "${BUNDLE_ID}\\n")
    file(APPEND env_file "${COMPANY_NAME}\\n")
endif ()
