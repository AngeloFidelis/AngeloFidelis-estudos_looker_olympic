view: calculations_age_medals {
  derived_table: {
    persist_for: "24 hours"
    sql: SELECT
      athletes.id,
      athletes.age,
      COUNT(medals.medal_type) AS medal_count,
      CAST(SUBSTRING(height, 1, 3) as INT64) AS height_number
      FROM `lookerstudylab.olympic_looker_dataset.athletes` AS athletes
      INNER JOIN `lookerstudylab.olympic_looker_dataset.medals` AS medals
      ON athletes.id = medals.id_athlete
      GROUP BY athletes.id, athletes.age, athletes.height ; ;;
  }

  parameter: select_operation {
    type: unquoted
    default_value: "age"
    allowed_value: {
      label: "Select Age"
      value: "age"
    }
    allowed_value: {
      label: "Select Height"
      value: "height"
    }
  }

  dimension: id {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    hidden: yes
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: medal_count {
    hidden: yes
    type: number
    sql: ${TABLE}.medal_count ;;
  }

  dimension: height_number {
    hidden: yes
    type: number
    sql: ${TABLE}.height_number ;;
  }


  measure: standard_deviation_calculation {
    type: number
    sql:
      {% if select_operation._parameter_value == 'age' %}
        ${standard_deviation_age}
      {% elsif select_operation._parameter_value == 'height' %}
        ${standard_deviation_height}
      {% endif %}
    ;;
    value_format: "#.##"
  }

  measure: correlation_medal_calculation {
    type: number
    sql:
      {% if select_operation._parameter_value == 'age' %}
        ${correlation_age_medal}
      {% elsif select_operation._parameter_value == 'height' %}
        ${correlation_height_medal}
      {% endif %}
    ;;
    value_format: "#.##"
  }

  measure: covariance_calculation {
    type: number
    sql:
      {% if select_operation._parameter_value == 'age' %}
        ${covariance_age}
      {% elsif select_operation._parameter_value == 'height' %}
        ${covariance_height}
      {% endif %}
    ;;
    value_format: "#.##"
  }

  measure: avg_calculation {
    type: number
    sql:
      {% if select_operation._parameter_value == 'age' %}
        ${avg_age}
      {% elsif select_operation._parameter_value == 'height' %}
        ${avg_height}
      {% endif %}
    ;;
    value_format: "#.##"
  }

  dimension: standard_deviation_title {
    type: string
    sql: 1 ;;
    html:
      <p>
        {% if select_operation._parameter_value == 'age' %}
          Standard Deviation Age
        {% elsif select_operation._parameter_value == 'height' %}
          Standard Deviation Height
        {% endif %}
      </p>
    ;;
  }

  dimension: correlation_medal_title {
    type: string
    sql: 1 ;;
    html:
      <p>
        {% if select_operation._parameter_value == 'age' %}
          Correlation Age Medal
        {% elsif select_operation._parameter_value == 'height' %}
          Correlation Height Medal
        {% endif %}
      </p>
    ;;
  }

  dimension: covariance_title {
    type: string
    sql: 1 ;;
    html:
      <p>
        {% if select_operation._parameter_value == 'age' %}
          Covariance Age
        {% elsif select_operation._parameter_value == 'height' %}
          Covariance Height
        {% endif %}
      </p>
    ;;
  }


  measure: standard_deviation_age {
    description: "statistical measure that quantifies the dispersion or variability of a data set relative to its mean"
    type: number
    sql: STDDEV_SAMP(${age}) ;;
    value_format: "#.##"
  }

  measure: correlation_age_medal {
    description: "measures the strength and direction of the linear relationship between two variables"
    type: number
    sql: CORR(${medal_count}, ${age}) ;;
    value_format: "#.##"
  }

  measure: covariance_age {
    description: "measures the direction of the linear relationship between two variables, but unlike correlation, it is not standardized. This means that covariance can take on any value and its interpretation depends on the units of the variables involved."
    type: number
    sql: COVAR_SAMP(${medal_count}, ${age}) ;;
    value_format: "#.##"
  }


  measure: correlation_height_medal {
    description: "statistical measure that quantifies the dispersion or variability of a data set relative to its mean"
    type: number
    sql: CORR(${medal_count}, ${height_number}) ;;
    value_format: "#.##"
  }

  measure: standard_deviation_height {
    description: "statistical measure that quantifies the dispersion or variability of a data set relative to its mean"
    type: number
    sql: STDDEV_SAMP(${height_number}) ;;
    value_format: "#.##"
  }

  measure: covariance_height {
    description: "measures the direction of the linear relationship between two variables, but unlike correlation, it is not standardized. This means that covariance can take on any value and its interpretation depends on the units of the variables involved."
    type: number
    sql: COVAR_SAMP(${medal_count}, ${height_number}) ;;
    value_format: "#.##"
  }

  measure: avg_age {
    type: average
    sql: ${age} ;;
    value_format: "#.##"
  }
  measure: avg_height {
    type: average
    sql: ${height_number} ;;
    value_format: "#.##"
  }
}
