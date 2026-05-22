# MkDocs Material for IBM Cloud Code Engine
FROM squidfunk/mkdocs-material:latest

# Set working directory
WORKDIR /docs

# Copy documentation files
COPY mkdocs.yml /docs/
COPY docs/ /docs/docs/

# Expose port (Code Engine will map this)
EXPOSE 8000

# Start MkDocs server
CMD ["serve", "--dev-addr=0.0.0.0:8000"]

# Made with Bob
