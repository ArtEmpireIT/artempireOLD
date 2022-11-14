/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('pertenencia', {
		id_pertenencia: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_pertenencia::regclass)",
			primaryKey: true
		},
		fecha_inicio: {
			type: DataTypes.DATE,
			allowNull: true
		},
		fecha_fin: {
			type: DataTypes.DATE,
			allowNull: true
		},
		precision_inicio: {
			type: DataTypes.STRING,
			allowNull: true
		},
		precision_fin: {
			type: DataTypes.STRING,
			allowNull: true
		},
		motivo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		orden: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		tipo_atr_doc: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_documento_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'documento',
				key: 'id_documento'
			}
		},
		fk_pertenencia_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'pertenencia',
				key: 'id_pertenencia'
			}
		}
	}, {
		tableName: 'pertenencia',
		timestamps: false
	});
};
