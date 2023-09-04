# Write some temp files to make GitHub Actions / packaging easy

if (ENV{CI} STREQUAL 1)
    message ("Writing ENV file for CI")
    set (env_file "${CMAKE_CURRENT_LIST_DIR}/.pamplejuce_env")
    file(APPEND env_file "${PROJECT_NAME}\\n")
    file(APPEND env_file "${PRODUCT_NAME}\\n")
    file(APPEND env_file "${BUNDLE_ID}\\n")
    file(APPEND env_file "${COMPANY_NAME}\\n")
endif ()
