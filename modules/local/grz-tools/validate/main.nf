process VALIDATE {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/grz-cli:1.5.0--pyhdfd78af_0' :
        'biocontainers/grz-cli:1.5.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(submissiondir)
    path(configfile)

    output:
    tuple val(meta), path(submissiondir) , emit: submissiondir
    path "versions.yml"                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args          = task.ext.args ?: ''
    def prefix        = task.ext.prefix ?: "${meta.id}"
    """
    grz-cli validate \\
        ${args} \\
        --submission-dir ${submissiondir} \\
        -- config-file ${configfile} \\
        --threads ${task.cpus}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        grz-cli: \$( grz-cli --version )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch progress_checksum_validation.cjson

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        grz-cli: \$( grz-cli --version )
    END_VERSIONS
    """
}
