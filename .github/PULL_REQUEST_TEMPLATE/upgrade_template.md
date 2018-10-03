---
name: Decidim upgrade
about: Upgrade Decidim gem version

---

**Checklist**

1. Upgrade Gemfile
2. Install new gems:

```bash
bundle install
```

3. Copy new migrations from Decidim:

```bash
bin/rails decidim:upgrade
```

4. Run new migrations:

```bash
bin/rails db:migrate
```

5. Run tests
6. Ensure changes made in [Campos de usuario personalizados] continue to work
7. Ensure newsletter preferences are kept, and that they are sent correctly
8. Ensure census integration works
