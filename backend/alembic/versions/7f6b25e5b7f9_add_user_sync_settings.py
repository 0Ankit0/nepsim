"""add user sync settings

Revision ID: 7f6b25e5b7f9
Revises: 012cc4845c3b
Create Date: 2026-03-25 02:45:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import sqlmodel


# revision identifiers, used by Alembic.
revision: str = "7f6b25e5b7f9"
down_revision: Union[str, Sequence[str], None] = "012cc4845c3b"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "usersyncsettings",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("backup_gemini_key_to_cloud", sa.Boolean(), nullable=False, server_default=sa.text("0")),
        sa.Column("encrypted_gemini_api_key", sqlmodel.sql.sqltypes.AutoString(length=4096), nullable=True),
        sa.Column("last_synced_at", sa.DateTime(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["user.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_usersyncsettings_user_id"), "usersyncsettings", ["user_id"], unique=True)


def downgrade() -> None:
    op.drop_index(op.f("ix_usersyncsettings_user_id"), table_name="usersyncsettings")
    op.drop_table("usersyncsettings")
