# Estudos looker
Esse projeto conta com dois arquivos de viewer: **athletes** (com informações sobre cada atleta) e **medals** (onde mostra as medalhes que cada atleta ganhou)

Além disso, dentro do arquivo model, há a junção do arquivo **athletes** com o arquivo **medals** através desse código:
```sql
explore: athletes {
  join: medals {
    type: inner
    sql_on: ${athletes.id} = ${medals.id_athlete} ;;
    relationship: one_to_many
  }
}
```
onde:
- `explore: athletes {}`: é uma definição que cria uma exploração (tipo um ponto de partida) para os usuários analisarem os dados chamada athletes (mesmo nome da view, isso significa que todos os dados presente no arquivo **athletes** irá aparecer no explorer **athletes**)
- `join: medals {}`: especifica uma junção com outra tabela ou visualização, onde nesse caso, vamos juntar a tabela **athletes** com a tabela **models**
- `type: inner`: especifica o tipo de junção usado, onde nesse caso, é uma junção interna (inner join), que retorna apenas os registros que têm correspondências nas duas tabelas
- `sql_on: ${athletes.id} = ${medals.id_athlete} ;;`: esta linha define a condição para a junção, onde serão retornados os campo quando o id da tabela **athletes** for igual ao campo **id_athlete** da tabela medals.
- `relationship: one_to_many`: especifica a natureza da relação entre as duas tabelas, indicando que um registro na tabela athletes pode corresponder a muitos registros na tabela medals.

<details>
  <summary>Componentes LookML</summary>

<details>
  <summary>Mudanças simples</summary>

### Configuração no arquivo medals.view
1. Dentro do arquivo **medals.view**, foi criado um componente `set` para realizar um drill_fields dentro da medida count, como no código abaixo:
    ```sql
    measure: count {
        type: count
        drill_fields: [show_details*]
    }
    set: show_details {
        fields: [
        athlete_name,
        country,
        medal_type,
        discipline,
        athletes.height,
        athletes.age
        ]
    }
    ```
    a. Isso permite especifica um conjunto de campos para detalhamento. Quando um usuário clicar para detalhar a medida count na interface do Looker, ele verá os campos definidos no conjunto show_details.

2. Dentro do arquivo **medals.view**, foi criando dois componentes: uma dimensão escondida do tipo `yesno` que retorna como verdadeiro (Yes) quandos os países forem igual ao "United States of America"; e uma medida do tipo `count` que conta as medalhas ganhas por atletas dos Estados Unidos aplicando um filtro para considerar apenas registros onde o país é "United States of America". E por fim permite detalhamento para ver mais informações sobre os atletas e suas medalhas.
    ```sql
    dimension: medal_usa_yesno{
        type: yesno
        hidden: yes
        sql: ${country} = "United States of America" ;;
    }

    measure: total_usa_medal {
        type: count
        label: "United States medals"
        --sql: ${medal_type} ;; o tipo `count` nao usa `sql`
        filters: [medal_usa_yesno: "Yes"]
        drill_fields: [athlete_name,country,medal_type,discipline]
    }
    ```
3. Dentro do arquivo **medals.view**, há a medida `count` para contar a quantidade de medalhas adquiridas, porém, houve atleta que ganhou mais de uma medalha. Para conseguirmos definir a quantidade de atletas que venceram e ganharam medalhas, vamos escrever o seguinte bloco de código:
    ```sql
    measure: count_winners {
        type: count_distinct
        sql: ${id_athlete} ;;
    }
    ```
4. [DELETADO]Dentro do arquivo **medals**, tinha sido criado uma medida que mostra a diferença entre o total de atletas e o total de atletas que ganharam medalhas. Pórem, como o tipo de junção no arquivo **model** está definido como `inner`, criar essa medida dentro do arquivo medels não irá funcionar como o esperado, pois o valor retornado será 0, tendo em vista que a quantidade de atletas totais será igual a quantidade de atletas que ganharam as medalhas, para esse bloco de código funcionar, é necessário definir o tipo da junção como `left_outer`. Porém, como essa medida não é tão relevante, foi deletada e o tipo de junção no arquivo **model** continua como `inner` entre os arquivos **athletes.view** e **medals.view**
    ```sql
    measure: athletes_that_win {
        type: number
        sql:COUNT(DISTINCT athletes.id) - COUNT(DISTINCT id_athlete );;
    }
    ```
5. Dentro do arquivo **medals**, foi criado um componente que conta a quantidade de medalhas que cada país ganhou, e foi implantado em uma medida diferente para que o drill_fields fosse diferente. Nesse caso, vamos poder detalhar a quantidade ganha de cada tipo de medalha por país
    ```sql
    measure: count_country_frequency {
        type: number
        sql: COUNT(${country}) ;;
        drill_fields: [medal_type, count]
    }
    ```

### Configuração no arquivo athletes.view

1. Dentro do arquivo **athletes.view**, foi criado um `set` semelhante ao criado no arquivo **medals**, só que nesse caso, irá realizar um drill_fields em todos os atletas, e não somente ao atletas que ganharam uma medalha.
    ```sql
    measure: count {
        type: count
        drill_fields: [show_details*]
    }

    set: show_details {
        fields: [
        name,
        country,
        medals.medal_type,
        discipline,
        athletes.height,
        athletes.age
        ]
    }
    ```

2. Dentro do arquivo **athletes.view**, foi criado uma dimensão do tipo `tier` que serve para categorizar algo. Nesse caso, foi usado para categorizar as idades de todos os participantes
    ```sql
    dimension: age_tier {
        type: tier
        tiers: [18, 25, 35, 45, 55, 65] --Define os limites dos intervalos (tiers)
        style: integer
        sql: ${age} ;;
    }
    ```

3. Dentro do arquivo **athletes.view**, foi criado uma dimensão do tipo number, que retorna a idade dos participantes (no código, é usado a data atual para fazer a diferença de idade, e não a data de quando os jogos foram realizados - 2021). Apesar de já ter uma coluna no banco de dados que mostra a idade dos jogadores, esse componente foi utilizado para praticar o trecho `DATE_DIFF(CURRENT_DATE, ${birth_date}, YEAR)`
    ```sql
    dimension: age_diff {
        type: number
        sql: DATE_DIFF(CURRENT_DATE, ${birth_date},YEAR) ;;
    }
    ```

4. Dentro do arquivo **athletes.view**, foi criado uma medida para calcular a media de idade dos atletas
    ```sql
    measure: avg_age {
        type: average
        sql: ${age} ;;
        value_format: "##.##"
    }
    ```

</details>

<details>
  <summary>Tabelas derivadas</summary>

As tabelas derivadas permitem criar novas tabelas que não existem fisicamente no banco de dados, mas são tratadas como tabelas normais dentro do Looker. Essas são úteis para realizar cálculos e análises complexas a partir de dados já existentes.

Neste contexto específico, as tabelas derivadas foram utilizadas para realizar os seguintes cálculos estatísticos:
- **Coeficiente de Correlação:** Calcula a relação linear entre as idades dos jogadores e a quantidade de medalhas conquistadas.
- **Desvio Padrão:** Mede a dispersão das idades dos jogadores em relação à média.
- **Covariância:** Avalia a tendência de mudança conjunta entre as idades dos jogadores e a quantidade de medalhas conquistadas.

Esta tabela derivada foi criada no SQL Runner utilizando a seguinte sintaxe SQL:
```sql
SELECT
  athletes.id,
  athletes.age,
  COUNT(medals.medal_type) AS medal_count
FROM `lookerstudylab.olympic_looker_dataset.athletes` AS athletes
INNER JOIN `lookerstudylab.olympic_looker_dataset.medals` AS medals
ON athletes.id = medals.id_athlete
GROUP BY athletes.id, athletes.age ;;
```

Após a criação inicial, foram feitas modificações no arquivo LookML conforme descrito abaixo:
- A medida **count** foi removida.
- A dimensão **id** foi configurada com os parâmetros `hidden: yes`, para não ser exibida no Explorer, e `primary_key: yes`, estabelecendo-a como a chave primária utilizada para junção no modelo.
- As dimensões **age** e **medal_count** também foram configuradas com `hidden: yes`, para não aparecerem no Explorer.
- Foram criadas as seguintes medidas: **standard_deviation**, **correlation_age_medal** e **covariance**.

```sql
view: calculations_age_medals {
  derived_table: {
    sql: SELECT
        athletes.id,
        athletes.age,
        COUNT(medals.medal_type) AS medal_count
      FROM `lookerstudylab.olympic_looker_dataset.athletes` AS athletes
      INNER JOIN `lookerstudylab.olympic_looker_dataset.medals` AS medals
      ON athletes.id = medals.id_athlete
      GROUP BY athletes.id, athletes.age ;;
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

  measure: standard_deviation {
    type: number
    sql: STDDEV_SAMP(${age}) ;;
    value_format: "#.##"
  }

  measure: correlation_age_medal {
    type: number
    sql: CORR(${medal_count}, ${age}) ;;
    value_format: "#.##"
  }

  measure: covariance {
    type: number
    sql: COVAR_SAMP(${medal_count}, ${age}) ;;
    value_format: "#.##"
  }
}

```

Nesse caso, os valores serão:
- **Coeficiente de Correlação:** -0.12 (Indica que à medida que a idade dos atletas aumenta, há uma tendência ligeira de que a quantidade de medalhas ganhas diminua. A relação é muito fraca e negativa)
- **Desvio Padrão:** 5.18 (Suponha que a média das idades dos atletas seja, por exemplo, 25 anos. Com um desvio padrão de 5.18, a maioria das idades dos atletas estará entre 25 - 5.18 (19.82) e 25 + 5.18 (30.18) anos. Isso indica uma variabilidade moderada na idade dos atletas.)
- **Covariância:** -0.41 (Indica que à medida que a idade dos atletas aumenta, a quantidade de medalhas tende a diminuir. A relação é negativa, mas a magnitude da covariância depende das unidades das variáveis)

### Persistindo os dados
As tabelas derivadas persistentes - PDTs - são gravadas e armazenadas no banco de dados conectado. As etapas para persistir uma tabela derivada são as mesmas, seja uma tabela derivada de SQL ou uma tabela derivada nativa

Primeiro, para persistir as tabelas, a opção de conexão com o banco de dados para persistir as tabelas derivadas precisa estar habilitada e configurada corretamente

Segundo, vamos utilizar uma dessas opções para persistir a tabela:
- `datagroup_trigger`: utiliza grupos de dados ou políticas de cache configurado no modelo para persistir os dados de tabelas derivadas
- `sql_trigger_value`: Uma uma instrução SELECT pré-escrita que retorna um valor, como o calor máximo de uma coluna de ID de usuário.
- `persist_for`: é usado para definir por quanto tempo a tabela derivada precisa ser armazenada após a execução da consulta antes de ser marcada como expirada
```
Nesse caso, usamos o persist_for com o valor de '24 hours'
```

</details>

<details>
  <summary>Extends</summary>

Os Extends permitem modularizar (dividir em partes pequenas chamadas de módulos, cada qual com uma função específica) o código criando cópias de objetos LookML que podem ser integrados a outros objetos LookML e modificados independentemente do objeto LookML original

### Extends na view
- Primeiro, vamos criar um arquivo view chamado **details_olympic.view**
- Dentro desse arquivo view, valor colocar o parâmetro `extension: required`, que significa que esta visualização não pode ser unida a outras visualizações e, portanto, não estará visível para os usuários.
- Vamos copiar as dimensões **country** e **discipline** para esse arquivo
```sql
view: details_olympic {
  extension: required

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension: discipline {
    type: string
    sql: ${TABLE}.discipline ;;
  }
}
```
Agora, para usarmos o extends, vamos aplicar a seguinte configuração nos arquivos **medals.view** e **athletes.view**
- Primeiro, vamos adcionar o parâmetro `include: details_olympic.view` no início do código
- Depois, vamos extender a view do arquivo **details_olympic.view** com o parâmetro `include: details_olympic.view`.
- Por fim, vamos deletar as dimensões **country** e **discipline** dos arquivos **medals.view** e **athletes.view**
- O código vai ficar mais ou menos assim:
```sql
include: details_olympic.view
view: medals {
  extends: [details_olympic]
  sql_table_name: `olympic_looker_dataset.medals` ;;
  ...
}
```

### Extends com Explorer
Para evitar reescrever as mesmas junções repetidamente, você pode fazer um Explore “base” que já os une e então estendê-lo para criar Explores adicionais que precisam juntar-se em mais visualizações.

Criei um outro explore com um nome qualquer, onde a view_name será a view **Athletes.view** e extendi as **joins** do explorer **athletes**. Nesse caso, o Explorer **athletes_extends** será igual ao Explorer **Athletes**
```sql
explore: athletes_extends {
  view_name: athletes
  extends: [athletes]
}
```

</details>

<details>
  <summary>Filtros no explore</summary>

Caso eu aplique algum filtro no explore, todos os looks criados nesse explorer configurado dentro do dash serão alterados. Então, será utilizado o novo explorer que foi extendido da explorer base (athletes)
- `sql_always_where e sql_always_having`: permitem adcionar filtros a um explore que nao podem ser modificados nem visualizados por usuários corporativos
- `always_filter`: Adciona um filtro ao explorer que pode ser acessado e ter seu valor alterado pelos usuários corporativos, porém os filtros não podem ser removidos
- `conditionally_filter`: Adciona um filtro ao frontend do explore que é acessível aos usuários corporativos. Nesse caso, os usuários podem remover os filtros se colocarem um filtro que foi especificado dentro do parâmetro `unless` no LookML
```sql
explore: athletes_extends {
  view_name: athletes
  sql_always_where: ${athletes.age} >= 18 AND ${athletes.age} <= 60 ;;
  always_filter: {
    filters: [athletes.gender: "Male"]
  }
  conditionally_filter: {
    filters: [medals.country: "United States of America"]
    unless: [medals.discipline, medals.medal_type]
  }
  extends: [athletes]
}
```
</details>

<details>
  <summary>Template Liquid</summary>

Existem 3 categorias de código Liquid:
- **Objetos**: variáveis ou espaços inseridos em tempo de execução reservados essencialmente utilizado para mostrar o conteúdo em uma página.
  - `{{ value }}`
- **Tags**: útil para criar a lógica e o fluxo de controle para os modelos. Eles permitem que você faça decisões condicionais, itere sobre listas de dados, inclua outros templates, atribuir variáveis, entre outros
  - `{% if user.admin %} ... {% endif %}`
- **Filtros**: manipulam a saída de um objeto
  - `{{ user.name | capitalize }}` -> Capitaliza o nome do usuário.

1. No arquivo **athletes.view**, foi usado o template liquid em duas situações: a primeira foi para mostrar uma cor de background como vermelho (idade menor que 18), verde (idade entre 18 e 60) e azul (idade maior que 60); a segunda foi para pesquisar na Internet o nome dos atletas. Foi utilizado somente **Objetos e Tags** nesses códigos
```sql
dimension: age {
  type: number
  sql: ${TABLE}.age ;;
  html:
    {% if value < 18 %}
      <p style="font-size:0.8rem; padding: 2px 0 2px 0; color:white; background-color:#CD6155; text-align:center;">{{value}}</p>
    {% elsif value >=18 and value <60 %}
      <p style="font-size:0.8rem; padding: 2px 0 2px 0; color:white; background-color:#1D8348; text-align:center;">{{value}}</p>
    {% else %}
      <p style="font-size:0.8rem; padding: 2px 0 2px 0; color:white; background-color:#0C7BDC; text-align:center;">{{value}}</p>
    {% endif %}
  ;;
}

dimension: name {
  type: string
  sql: ${TABLE}.name ;;
  link: {
    label: "Google"
    url: "https://www.google.com/search?q={{ name }}"
    icon_url: "https://www.google.com/images/branding/product/ico/googleg_lodp.ico"
  }
}
```

2. No arquivo **deteils_olympic.view**, foi utilizado o template Liquid na dimensão "country" para permitir a pesquisa dos nomes dos países na internet. Além disso, foi aplicado a categoria filter do template Liquid para extrair as duas primeiras letras do nome do país e convertê-las para minúsculas. Isso facilita a busca pelo ícone da bandeira correspondente, que é exibido no explore.

```sql
dimension: country {
  type: string
  map_layer_name: countries
  sql: ${TABLE}.country ;;
  link: {
    label: "Google"
    url: "https://www.google.com/search?q={{ value }}"
    icon_url: "https://flagcdn.com/w320/{{ value | downcase | slice:0,2 }}.png"
  }
}
```

3. No arquivo **medals.view**, foi utilizado o template Liquid para exibir informações do atleta, incluindo o nome, o modelo utilizado pela dimensão, o link e a idade proveniente de outro arquivo
```sql
dimension: data_athletes {
  type: string
  sql: ${athlete_name} ;;
  html:
    <ul>
      <li>Nome: {{ value }}</li>
      <li>Model: {{ _model._name }}</li>
      <li>Link: {{ link }}</li>
      <li>Rendered Value: {{ rendered_value }}</li>
      <li>Age: {{ athletes.age._value }}</li>
    </ul>
    ;;
}
```


</details>

<details>
  <summary>Parameter liquid</summary>
Dentro do looker, há um objeto chamado parameter que usam a linguagem liquid para aumentar a interatividade em Explorer, looks e dashboards. O caso de uso para isso é que às vezes você deseja mais flexibilidade para influenciar o SQL gerado.

### Filtrar a quantidade de medalhas por mês
Só há registro de dois meses de jogos dentro do dataset, e meu objetivo era filtrar os dados com base no valor do Parameter Liquid selecionado. Além disso, criei um card mostrando o mês que foi selecionado
```sql
parameter: month_select{
    type: unquoted
    allowed_value: {
      label: "First month (July)"
      value: "7"
    }
    allowed_value: {
      label: "Last month (August)"
      value: "8"
    }
  }

  dimension: medals_by_month_select {
    type: string
    sql:
      CASE
        WHEN
          CAST(SUBSTR(${medal_month},6,2) AS INT) = {% parameter month_select %}
        THEN medal_type
      END ;;
  }

  dimension: title_dynamic_month {
    sql: ${medals_by_month_select} ;;
    html:
      <a href="#drillmenu" target="_self">
        {% if month_select._parameter_value == '7' %}
        Month of July
        {% elsif month_select._parameter_value == '8' %}
        Month of August
        {% endif %}
      </a>
    ;;
    drill_fields: [show_details*]
  }
```

</details>

<details>
  <summary>Filter Liquid</summary>

São valores inseridos pelo usuário que são passados para consultas SQL usando lógica condicional escrita de forma inteligente e permitindo criar dimensões e medidas dinâmicas.

```sql
filter: select_discipline {
  label: "Discipline"
  type: string
  suggest_explore: athletes
  suggest_dimension: discipline
}

dimension: athletes_by_discipline {
  label: "Athletes"
  type: string
  sql:
    CASE
      WHEN
        {% condition select_discipline %}
          ${discipline}
        {% endcondition %}
      THEN ${athlete_name}
    END
  ;;
  link: {
    label: "Google"
    url: "https://www.google.com/search?q={{ value }}"
    icon_url: "https://fontawesome.com/icons/google?f=brands&s=solid"
  }
  drill_fields: [show_details*]
}

dimension: qtd_medal_by_discipline {
  type:string
  sql:
    CASE
      WHEN
        {% condition select_discipline %}
          ${discipline}
        {% endcondition %}
      THEN ${medal_type}
    END
  ;;
  drill_fields: [show_details*]
}
```


</details>

</details>

---

<details>
  <summary>Dashboard criado</summary>

### Primeiro Look
O primeiro look criado é um look que mostra a diferença do total de medalhas ganhas entre homens e mulheres com base no tipo da medalha. Esse look foi criado da seguinte forma:
- Primeiro, selecionei a dimensão **Medal Type** na viwer **Medals**
- Depois, selecionei a dimensão **Gender** como um _pivot_ na viwer **Athletes**
- Por fim, selecionei a medida **Count** da viwer **Medals**

### Segundo Look
O segundo look criado é um look que mostra a quantidade de atletas totais que competiram com base no intervalo de idade deles. Foi utilizado um gráfico de área nesse look. Esse look foi criado da seguinte forma
- Primeiro, selecionei a dimensão **Age tier** na viwer **Athletes**
- Por fim, selecionei a medida **Count** da viwer **Athletes**

### Terceiro Look
O terceiro look criado é um gráfico que exibe a quantidade de medalhas ganhas por cada atleta. Este gráfico de linha mostra a diferença de idade entre os atletas e os tipos de medalhas que eles ganharam. Esse look foi criado da seguinte forma:
- Primeiro, selecionei a dimensão **Age** na viwer **Athletes**
- Depois, selecionei a dimensão **Medal Type** como um _pivot_ na viwer **Medals**
- Por fim, selecionei a medida **Count** da viwer **Medals**

### Quarto Look
O quarto look criado é um gráfico de valor único que mostra a quantidade de medalhas conquistadas na olimpíada. Esse gráfico foi feito para mostrar que, se o tipo de junção no arquivo **model** estivesse como `left_outer`, agora, quando eu clicasse no valor do gráfico para o detalhamento através do `drill_fields`, haveria dados nulos. Porém, com o tipo de junção `inner`, não há dados nulos

### Quinto Look
O quinto look é do tipo google Maps, e mostra a quantidade de medalhas que cada país ganhou, separados pelos tipos de medalha. Esse look foi criado da seguinte forma:
- Primeiro, selecionei a dimensão **Country** na viwer **Medals**
- Por fim, selecionei a medida **Count Country Frequency** na viwer **Medals**

### Sexto Look
O sexto look é do tipo Pizza (pie), e mostra a porcentagem de cada tipo de medalha conquistada.
- Depois, selecionei a dimensão **Medal Type** na viwer **Medals**
- Por fim, selecionei a medida **Count** da viwer **Medals**

[OBERSEVAÇÃO]: Eu poderia ter criado esse look como uma tabela dentro do drill_fields do Quarto Look (visualização única), porém foi feito dessa forma para poder testar o gráfico de pizza

### Setimo Look
O setimo look foi criado usando duas medidas: o desvio padrão das idades e a média das idades. O intuito dessa tabela é demostrar a variabilidade relativa da idade dos atletas em relação à média. Esse look foi criado da seguinte forma:
- Primeiro, selecionei a medida **Standard Deviation** na view **Calculations Age Medals**
- Depois, selecionei a medida **Avg Age** na view **Athletes**
- Depois, de clicar em Run, selecionei o Look "Single Value"
- Por fim, cliquei em "Edit -> Comparison -> Show -> Calculate Progress (With Porcentage)"

</details>
